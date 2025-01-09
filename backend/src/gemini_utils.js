// import { GoogleGenerativeAI } from "@google/generative-ai";
const { GoogleGenerativeAI } = require("@google/generative-ai");
const genAI = new GoogleGenerativeAI("AIzaSyAkCOT7ALfjPT0fojb2AxwxWATS_Sam94A");
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

async function promptGemini(prompt) {
    try {
        const result = await model.generateContent(prompt);
        console.log(result.response.text());
        return result.response.text();
    }
    catch (err) {
        console.error(err);
    }
}

const labelFullForms = {
    'mel': 'Melanoma',
    'nv': 'Melanocytic nevus',
    'bcc': 'Basal cell carcinoma',
    'akiec': 'Actinic keratosis',
    // Bowen\'s disease (intraepithelial carcinoma)
    'bkl': 'Benign keratosis',
    // (solar lentigo / seborrheic keratosis / lichen planus-like keratosis)
    'df': 'Dermatofibroma',
    'vasc': 'Vascular lesion',
};

async function respond(messages, label) {
    let prompt = "You being Skin Sure bot reply accordingly to the last msg of the user:\n";
    prompt += "Skin Sure Bot: " + `You have been diagnosed with skin disease: '${labelFullForms[label]}'` + '\n';
    for (const message of messages) {
        if (message.from === 'user') {
            prompt += "User: " + message.txt + '\n';
        } else {
            prompt += "Skin Sure Bot: " + message.txt + '\n';
        }
    }
    const response = await promptGemini(prompt);
    return response;
}

module.exports = { promptGemini, respond };