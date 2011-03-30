# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils versionator

DESCRIPTION="Geographic Objects for PostgreSQL"
HOMEPAGE="http://postgis.refractions.net"
SRC_URI="http://postgis.refractions.net/download/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc"

RDEPEND=">=dev-db/postgresql-server-8.3
	>=sci-libs/geos-3.2
	>=sci-libs/proj-4.6.0
	dev-libs/libxml2:2"

DEPEND="${RDEPEND}
	doc? ( app-text/docbook-xsl-stylesheets
		app-text/docbook-xml-dtd:4.3
		media-gfx/imagemagick )"

RESTRICT="test"

PGSLOT="$(eselect postgresql show)"
[ "${PGSLOT}" = "(none)" ] && die "You must select a PostgreSQL slot before emerging this package."

pkg_setup(){
	if [ ! -z "${PGUSER}" ]; then
		eval unset PGUSER
	fi
	if [ ! -z "${PGDATABASE}" ]; then
		eval unset PGDATABASE
	fi
	local tmp
	tmp="$(portageq match / ${CATEGORY}/${PN} | cut -d'.' -f2)"
	if [ "${tmp}" != "$(get_version_component_range 2)" ]; then
		elog "You must soft upgrade your existing postgis enabled databases"
		elog "by adding their names in the ${ROOT}conf.d/postgis_dbs file"
		elog "then using 'emerge --config postgis'."
		require_soft_upgrade="1"
		ebeep 2
	fi
}

src_configure(){
	local myconf
	if use doc; then
		myconf="${myconf} --with-xsldir=$(ls "${ROOT}"usr/share/sgml/docbook/* | \
			grep xsl\- | cut -d':' -f1)"
	fi

	econf  \
		--datadir=/usr/share/postgresql-${PGSLOT}/contrib/ \
		--libdir=/usr/$(get_libdir)/postgresql-${PGSLOT}/lib/ \
		--docdir="${D}/usr/share/doc/${PF}/html/" \
		${myconf} ||\
			die "Error: econf failed"

	if use doc; then
		cd doc
		sed -i -e 's:PGSQL_DOCDIR=/:PGSQL_DOCDIR=${D}/:' Makefile || die "Fixing doc install paths failed"
		sed -i -e 's:PGSQL_MANDIR=/:PGSQL_MANDIR=${D}/:' Makefile || die "Fixing doc install paths failed"
		sed -i -e 's:PGSQL_SHAREDIR=/:PGSQL_SHAREDIR=${D}/:' Makefile || die "Fixing doc install paths failed"
	fi
}

src_compile() {
	emake -j1 || die "Error: emake failed"

	cd topology/
	emake -j1 || die "Unable to build topology sql file"

	if use doc ; then
		cd "${S}"
		emake -j1 docs || die "Unable to build documentation"
	fi
}

src_install(){
	dodir /usr/$(get_libdir)/postgresql-${PGSLOT}	/usr/share/postgresql-${PGSLOT}/contrib/
	emake DESTDIR="${D}" install || die "emake install failed"
	cd "${S}/topology/"
	emake DESTDIR="${D}" install || die "emake install topology failed"

	cd "${S}"
	dodoc CREDITS TODO loader/README.* doc/*txt

	docinto topology
	dodoc topology/{TODO,README}
	dobin ./utils/postgis_restore.pl

	cd "${S}"
	if use doc; then
		emake DESTDIR="${D}" docs-install || die "emake install docs failed"
	fi

	echo "template_gis" > postgis_dbs
	doconfd postgis_dbs

	#if [ ! -z "${require_soft_upgrade}" ]; then
		grep "'C'" -B 4 -A 1 "${D}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/postgis.sql | \
			grep -v "'sql'" > \
				"${D}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/load_before_upgrade.sql
	#fi
}

pkg_postinst() {
	elog "To create new (upgrade) spatial databases add their names in the"
	elog "${ROOT}etc/conf.d/postgis_dbs file, then use 'emerge --config postgis'."
}

pkg_config(){
	einfo "Create or upgrade a spatial templates and databases."
	einfo "Please add your databases names into ${ROOT}etc/conf.d/postgis_dbs"
	einfo "(templates name have to be prefixed with 'template')."
	source "${ROOT}"etc/conf.d/postgresql-${PGSLOT}
	[ -S /var/run/postgresql/.s.PGSQL.${PGPORT} ] || die "The PostgreSQL server	must be running and listening on /var/run/postgresql/.s.PGSQL.${PGPORT}"
	for i in $(cat "${ROOT}etc/conf.d/postgis_dbs"); do
		PGDATABASE=${i}
		eval set PGDATABASE=${i}
		myuser="${PGUSER:-postgres}"
		mydb="${PGDATABASE:-template_gis}"
		eval set PGUSER=${myuser}

		is_template=false
		if [ "${mydb:0:8}" == "template" ];then
			is_template=true
			mytype="template database"
		else
			mytype="database"
		fi

		einfo
		einfo "Using the user ${myuser} and the ${mydb} ${mytype}."

		logfile=$(mktemp "${ROOT}tmp/error.log.XXXXXX")
		safe_exit(){
			eerror "Removing created ${mydb} ${mytype}"
			dropdb -p ${PGPORT} -U "${myuser}" "${mydb}" ||\
				(eerror "${1}"
				die "Removing old db failed, you must do it manually")
			eerror "Please read ${logfile} for more information."
			die "${1}"${logfile}
		}

	# if there is not a table or a template existing with the same name, create.
		if [ -z "$(psql -U ${myuser} -l | grep "${mydb}")" ]; then
			createdb -p ${PGPORT} -O ${myuser} -U ${myuser} ${mydb} ||\
				die "Unable to create the ${mydb} ${mytype} as ${myuser}"
			createlang -p ${PGPORT} -U ${myuser} plpgsql ${mydb}
			#if [ "$?" == 2 ]; then
				#safe_exit "Unable to createlang plpgsql ${mydb}."
			#fi
			(psql -p ${PGPORT} -q -U ${myuser} ${mydb} -f \
				"${ROOT}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/postgis.sql &&
			psql -p ${PGPORT} -q -U ${myuser} ${mydb} -f \
				"${ROOT}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/spatial_ref_sys.sql) 2>\
					"${logfile}"
			if [ "$(grep -c ERROR "${logfile}")" \> 0 ]; then
				safe_exit "Unable to load sql files."
			fi
			if ${is_template}; then
				psql -p ${PGPORT} -q -U ${myuser} ${mydb} -c \
					"UPDATE pg_database SET datistemplate = TRUE
					WHERE datname = '${mydb}';
			GRANT ALL ON table spatial_ref_sys, geometry_columns TO PUBLIC;" \
				|| die "Unable to create ${mydb}"
			psql -p ${PGPORT} -q -U ${myuser} ${mydb} -c \
				"VACUUM FREEZE;" || die "Unable to set VACUUM FREEZE option"
			fi
		else
			if [ $(psql -p ${PGPORT} -q -U ${myuser} ${mydb} -c "SELECT COUNT(*) FROM pg_proc WHERE proname='postgis_lib_version'" | head -n 3 | tail -n 1 | tr -d ' \n') == 0 ];
			then
				# existing db but not spatially enabled
				einfo "'${mydb}' is not spatially enabled. Installing postgis SQL in it"
				(psql -p ${PGPORT} -q -U ${myuser} ${mydb} -f \
					"${ROOT}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/postgis.sql &&
				psql -p ${PGPORT} -q -U ${myuser} ${mydb} -f \
					"${ROOT}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/spatial_ref_sys.sql) 2>\
						"${logfile}"
				if [ "$(grep -c ERROR "${logfile}")" \> 0 ]; then
					eerror "Unable to load sql files."
					die "see ${logfile} for details"
				fi
			else
				# spatially enabled db. soft-upgrade it
				if [ -e "${ROOT}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/load_before_upgrade.sql ];
				then
					einfo "Updating the dynamic library references"
					psql -p ${PGPORT} -q -U ${myuser} ${mydb} -f \
						"${ROOT}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/load_before_upgrade.sql\
							2> "${logfile}"
					if [ "$(grep -c ERROR "${logfile}")" \> 0 ]; then
						eerror "Unable to update references."
						die "see ${logfile} for details"
					fi
				fi
				if [ -e "${ROOT}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/postgis_upgrade_15_minor.sql ];
				then
					einfo "Running soft upgrade"
					psql -p ${PGPORT} -q -U ${myuser} ${mydb} -f \
						"${ROOT}"usr/share/postgresql-${PGSLOT}/contrib/postgis-1.5/postgis_upgrade_15_minor.sql 2>\
							"${logfile}"
					if [ "$(grep -c ERROR "${logfile}")" \> 0 ]; then
						eerror "Unable to run soft upgrade."
						die "see ${logfile} for details"
					fi
				fi
			fi
		fi
		if ${is_template}; then
			einfo "You can now create a spatial database using :"
			einfo "'createdb -T ${mydb} test'"
		fi
	done
}
