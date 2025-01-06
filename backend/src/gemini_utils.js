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

module.exports = { promptGemini };