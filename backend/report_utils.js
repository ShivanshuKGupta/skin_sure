const fs = require('fs');

async function updateReport(report) {
    let reportData = {};
    try {
        const data = fs.readFileSync('python/public/reports.json', 'utf8');
        reportData = JSON.parse(data);
    }
    catch (e) {
        console.error(e);
    }
    reportData[report.id] = report;
    fs.writeFileSync('python/public/reports.json', JSON.stringify(reportData));
}

exports.updateReport = updateReport;