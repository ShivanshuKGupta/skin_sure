const { updateReport, deleteReport } = require("./report_utils");

class Report {
    constructor(
        id,
        imgPath = null,
        label = null,
        segImagePath = null,
        gender = null,
        age = null,
        location = null,
        causes = null,
        treatment = null,
        precautions = null
    ) {
        this.id = id;
        this.imgPath = imgPath;
        this.label = label;
        this.segImagePath = segImagePath;
        this.gender = gender;
        this.age = age;
        this.location = location;
        this.causes = causes;
        this.treatment = treatment;
        this.precautions = precautions;
    }

    async update() {
        await updateReport(this);
    }

    async delete() {
        await deleteReport(this.id);
    }
}

module.exports = Report;