const express = require('express');
const multer = require('multer');
const path = require('path');
const { exec } = require('child_process');

const app = express();
const PORT = 3000;

app.use('/public', express.static('public'));
app.use(express.json());

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/');
    },
    filename: (req, file, cb) => {
        const timestamp = Date.now();
        const extension = path.extname(file.originalname);
        const fileName = `${timestamp}${extension}`;
        cb(null, fileName);
    },
});

const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Only image files are allowed!'), false);
    }
};

const upload = multer({ storage, fileFilter });

app.post('/segment', upload.single('image'), (req, res) => {
    try {
        const fileName = req.file.filename;
        const filePath = `public/${fileName}`;
        const id = fileName.split('.')[0];
        const segFilePath = `public/${id}_seg.png`;

        const cmd = `python ./python/segment.py ${filePath} ${segFilePath}`;

        exec(cmd, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error code: ${error.code}`);
                console.error(`Error message: ${error.message}`);
                res.status(400).json({ error: error.message });
                return;
            }

            console.log(`Standard Output:\n${stdout}`);
            if (stderr) {
                console.error(`Standard Error:\n${stderr}`);
                res.status(400).json({ error: stderr });
            }

            console.log('Segmentation completed');

            const report = {
                "id": id,
                "imgUrl": filePath,
                "class": null,
                "seg_image_url": segFilePath,
                "suggestions": null,
            };

            res.status(200).json({ report });
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.post('/classify', (req, res) => {
    try {
        const { id } = req.body;
        const filePath = `public/${id}.png`;
        const segFilePath = `public/${id}_seg.png`;

        const cmd = `python ./python/classify.py ${segFilePath}`;

        exec(cmd, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error code: ${error.code}`);
                console.error(`Error message: ${error.message}`);
                res.status(400).json({ error: error.message });
                return;
            }

            console.log(`Standard Output:\n${stdout}`);
            if (stderr) {
                console.error(`Standard Error:\n${stderr}`);
                res.status(400).json({ error: stderr });
            }

            console.log('Classfication completed');

            const lines = stdout.trim().split('\n');
            const label = lines[lines.length-1].trim();

            const report = {
                "id": id,
                "imgUrl": filePath,
                "class": `${label}`,
                "seg_image_url": segFilePath,
                "suggestions": "hehe",
            };

            res.status(200).json({ report });
        });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

app.listen(PORT, () => {
    console.log(`Server started on http://localhost:${PORT}`);
});