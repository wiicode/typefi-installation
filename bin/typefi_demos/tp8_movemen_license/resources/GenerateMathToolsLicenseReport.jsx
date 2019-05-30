
(function () {
	//TYPEFI = {log: {info: function (m) {$.writeln (m)}}};
	TYPEFI.log.info ('-------------------------------------------------------------------------------');
	if (!app.hasOwnProperty ('mtVersion')) {
		TYPEFI.log.warn ('MathTools not installed');
	} else {
		TYPEFI.log.info ('Installed MathTools version: ' + app.mtVersion);
		var report = app.mtGenerateLicenseReport();
		//TYPEFI.log.info ('MathTools licence report: ' + report);
		var name = File(report).name;
		File(report).copy (File (TYPEFI.job.folder+'/'+name));
		TYPEFI.log.info ('Copied the licence report to ' + TYPEFI.job.folder);
	}
	TYPEFI.log.info ('------------------------------------------------------------------------------');
}());
