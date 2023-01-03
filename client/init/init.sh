iris start $ISC_PACKAGE_INSTANCENAME
iris session $ISC_PACKAGE_INSTANCENAME < ${INIT_DIR}/init.cos
iris stop $ISC_PACKAGE_INSTANCENAME quietly

cp ${INIT_DIR}/html/* /usr/irissys/csp/demo/

rm -f $ISC_PACKAGE_INSTALLDIR/mgr/journal.log
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/IRIS.WIJ
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/iris.ids
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/alerts.log
rm -f $ISC_PACKAGE_INSTALLDIR/mgr/journal/*
: > $ISC_PACKAGE_INSTALLDIR/mgr/messages.log
# rm -fr ${INIT_DIR}/init
