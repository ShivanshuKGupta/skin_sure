const { promptGemini } = require("./gemini_utils");

async function getSuggestions(label) {
    try {
        return await promptGemini(`You are a medical assistant named "Skin Sure" specialized in dermatology, and your task is to provide clear and concise information for patients diagnosed with specific skin diseases. For each condition, please provide the following:

Causes: Describe the common causes or risk factors for developing the condition.
Treatment Options: List the most widely recommended treatments, including medical, procedural, and home-care options.
Precautions and Prevention: Suggest practical precautions to prevent the progression of the condition or reduce the likelihood of recurrence.

The skin disease to provide information for is: ${label}
Make sure the responses are detailed enough to be informative yet simple enough for a non-specialist to understand. Use medical terminology sparingly and always explain any technical terms you use.`);
    }
    catch (error) {
        console.error(error);
        return `Error: Unable to generate response: ${error}`;
    }
}

exports.getSuggestions = getSuggestions;