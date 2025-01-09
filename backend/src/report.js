const { updateReport, deleteReport } = require("./report_utils");

class Report {
    constructor(
        id,
        imgPath = null,
        label = null,
        segImagePath = null,
        messages = [],
    ) {
        this.id = id;
        this.imgPath = imgPath;
        this.label = label;
        this.segImagePath = segImagePath;
        this.messages = messages;
    }

    async update() {
        await updateReport(this);
    }

    async delete() {
        await deleteReport(this.id);
    }
}

module.exports = Report;