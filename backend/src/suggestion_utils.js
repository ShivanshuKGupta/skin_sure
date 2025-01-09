const { promptGemini, labelFullForms } = require("./gemini_utils");
const fs = require('fs');

async function getSuggestions(label) {
    const prompt = `
You are a medical assistant named "Skin Sure" specialized in dermatology, and your task is to provide clear and concise information for patients diagnosed with specific skin diseases. For each condition, please provide the following:

Causes: Describe the common causes or risk factors for developing the condition.
Treatment Options: List the most widely recommended treatments, including medical, procedural, and home-care options.
Precautions and Prevention: Suggest practical precautions to prevent the progression of the condition or reduce the likelihood of recurrence.

The skin disease to provide information for is: ${labelFullForms[label]}
Make sure the responses are detailed enough to be informative yet simple enough for a non-specialist to understand. Use medical terminology sparingly and always explain any technical terms you use.`;

    const cachedResponses = fs.existsSync('python/public/cached_responses.json') ?
        JSON.parse(fs.readFileSync('python/public/cached_responses.json', 'utf8')) :
        {};
    if (cachedResponses[prompt]) {
        return cachedResponses[prompt];
    }
    try {
        const response = await promptGemini(prompt);
        cachedResponses[prompt] = response;
        fs.writeFileSync('python/public/cached_responses.json', JSON.stringify(cachedResponses, null, 4));
        return response;
    }
    catch (error) {
        console.error(error);
        return `Error: Unable to generate response: ${error}`;
    }
}

exports.getSuggestions = getSuggestions;