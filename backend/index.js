const express = require('express');
const multer = require('multer');
const path = require('path');
const { exec } = require('child_process');
const { updateReport, deleteReport, getAllReports } = require('./src/report_utils');
const { getSuggestions } = require('./src/suggestion_utils');
const { startSegmentProcess, getSegment, endSegmentProcess } = require('./src/segment');
const { classifyImage, endClassifyProcess, startClassifyProcess } = require('./src/classify');
const { respond, labelFullForms } = require('./src/gemini_utils');

const app = express();
const PORT = 3000;

app.use('/public', express.static('python/public'));
app.use(express.json());

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'python/public/');
    },
    filename: (req, file, cb) => {
        const timestamp = Date.now();
        const extension = path.extname(file.originalname);
        const fileName = `${timestamp}${extension}`;
        cb(null, fileName);
    },
});

const fileFilter = (req, file, cb) => {
    cb(null, true);
};

const upload = multer({ storage, fileFilter });

app.post('/segment', upload.single('image'), async (req, res) => {
    try {
        console.log('File uploaded successfully');
        const fileName = req.file.filename;
        const filePath = `public/${fileName}`;
        const id = fileName.split('.')[0];
        const segFilePath = `public/${id}_seg.jpg`;

        await getSegment(filePath, segFilePath, res, () => {
            const report = {
                "id": id,
                "imgUrl": filePath,
                "class": null,
                "seg_image_url": segFilePath,
                "suggestions": null,
            };

            updateReport(report);

            res.status(200).json({ report });
        });
    } catch (error) {
        console.error(error);
        res.status(400).json({ error: error.message });
    }
});

app.post('/classify', async (req, res) => {
    try {
        const { id } = req.body;
        const filePath = `public/${id}.jpg`;
        const segFilePath = `public/${id}_seg.jpg`;

        await classifyImage(filePath, segFilePath, res, async (data) => {
            console.log(`data = `, data);
            const lines = data.trim().split('\n');
            const lastLine = lines[lines.length - 1].trim();
            const label = lastLine.split('PREDICTION:')[1].trim();

            const report = {
                "id": id,
                "imgUrl": filePath,
                "class": `${label}`,
                "seg_image_url": segFilePath,
                "suggestions": null,
            };

            if (!report.messages) {
                report.messages = [
                    {
                        'id': new Date().toISOString(),
                        'txt': `You have been diagnosed with skin disease: **${labelFullForms[label]}**`,
                        'from': 'bot',
                        'indicative': true,
                        'createdAt': new Date().getTime(),
                    },
                    {
                        'id': new Date().toISOString(),
                        'txt': await getSuggestions(label),
                        'from': 'bot',
                        'indicative': false,
                        'createdAt': new Date().getTime(),
                    }
                ];
            }
            await updateReport(report);

            res.status(200).json({ report });

        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.post('/delete-report', async (req, res) => {
    try {
        const { id } = req.body;
        const filePath = `${id}.jpg`;
        const segFilePath = `${id}_seg.jpg`;

        const cmd = `del "${filePath}" "${segFilePath}"`;

        await deleteReport(id);

        exec(cmd, { cwd: 'python/public' }, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error code: ${error.code}`);
                console.error(`Error message: ${error.message}`);
                res.status(400).json({ error: error.message });
                return;
            }

            console.log(`Standard Output:\n${stdout}`);
            if (stderr) {
                console.error(`Standard Error:\n${stderr}`);
            }

            console.log('Files deleted successfully');
            res.status(200).json({ message: 'Files deleted successfully' });
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.post('/generate-suggestions', async (req, res) => {
    try {
        const { id } = req.body;
        const reports = getAllReports();
        const report = reports[id];
        const suggestions = await getSuggestions(report['class']);
        report.suggestions = suggestions;
        res.status(200).json({ report });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.post('/add-message', async (req, res) => {
    try {
        const { id, message } = req.body;
        const reports = await getAllReports();
        const report = reports[id];
        if (!report.messages) {
            report.messages = [];
        }
        report.messages.push(message);
        const response = await respond(report.messages, report['class']);
        const botMessage = {
            'id': new Date().toISOString(),
            'txt': response,
            'from': 'bot',
            'indicative': false,
            'createdAt': new Date().getTime(),
        };
        report.messages.push(botMessage);
        console.log(`reports = `, reports);
        console.log(`report = `, report);
        await updateReport(report);
        res.status(200).json({ report });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.listen(PORT, async () => {
    await startSegmentProcess();
    await startClassifyProcess();
    console.log(`Server started on http://localhost:${PORT}`);
});

/// add listeners to SIGINT and SIGTERM signals
process.on('SIGINT', async () => {
    console.log('Server shutting down');
    endSegmentProcess();
    endClassifyProcess();
    process.exit(0);
});