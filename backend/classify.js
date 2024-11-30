const { spawn } = require('child_process');
const { exit } = require('process');

let pythonProcess;

async function startClassifyProcess() {
    pythonProcess = spawn('python', ['classify.py'], {
        cwd: 'python'
    });

    pythonProcess.on('error', (err) => {
        console.error('Failed to start classify process:', err);
        exit(1);
    });

    pythonProcess.stdout.on('data', (data) => {
        console.log(data.toString());
    });
    pythonProcess.stderr.on('data', (data) => {
        console.error(data.toString());
    });

    console.log('Python process started');
}

async function classifyImage(filePath, segFilePath, res, onComplete) {
    if (!pythonProcess) {
        res.status(500).send('Process did\'nt start! Try again after some time.');
        return;
    }

    let result = '';
    let error = '';

    const stdoutListener = (data) => {
        result += data.toString();
        onComplete(result);
        pythonProcess.stdout.removeListener('data', stdoutListener);
        pythonProcess.stderr.removeListener('data', stderrListener);
    };

    const stderrListener = (data) => {
        error += data.toString();
        if (data.toString().includes('Error:')) {
            res.status(500).send({ error: 'Error occurred during processing', details: error });
            pythonProcess.stdout.removeListener('data', stdoutListener);
            pythonProcess.stderr.removeListener('data', stderrListener);
        }
    };

    pythonProcess.stdout.on('data', stdoutListener);
    pythonProcess.stderr.on('data', stderrListener);

    pythonProcess.stdin.write(`${segFilePath}\n`);

    pythonProcess.once('close', (code) => {
        pythonProcess.stdout.removeListener('data', stdoutListener);
        pythonProcess.stderr.removeListener('data', stderrListener);
        console.log('Python process closed with code:', code);

        if (error) {
            console.error('Error:', error);
        }
    });
}

async function endClassifyProcess() {
    if (!pythonProcess) {
        console.log('No active process to end.');
        return;
    }
    pythonProcess.stdin.end();
    pythonProcess.kill();
    pythonProcess = null;
}

module.exports = {
    startClassifyProcess,
    classifyImage,
    endClassifyProcess
};