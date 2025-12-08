import openai
import os

openai.api_key = os.environ.get('OPENAI_API_KEY')

if openai.api_key == None:
    print("Missing API Key")
    exit(1)

languages = {
    "German": "deDE",
    "Spanish (Spain)": "esES",
    "Spanish (Mexico)": "esMX",
    "French": "frFR",
    "Korean": "koKR",
    "Russian": "ruRU",
    "Simplified Chinese": "zhCN",
    "Traditional Chinese": "zhTW"
}

def translate_lua(localization_string, target_language):
    # Construct the prompt
    prompt = f"Translate the following Lua localization code to {target_language}:\n\n{localization_string}, don't change the keys, only change the values, and don't translate the comments."

    # Make the API call
    response = openai.chat.completions.create(
        model="gpt-5",
        messages=[
            {"role": "system", "content": "You are a helpful assistant who translates code."},
            {"role": "user", "content": prompt}
        ],
    )

    # Extract the translated Lua code
    translated_code = response.choices[0].message.content.strip()
    return translated_code

def process_file(input_file, output_folder):
    with open(input_file, 'r', encoding='utf-8') as file:
        lua_code = file.read()

    for language_name, language_code in languages.items():
        translated_code = translate_lua(lua_code, language_name)
        output_file = os.path.join(output_folder, f"{language_code}.lua")
        
        with open(output_file, 'w', encoding='utf-8') as out_file:
            out_file.write(translated_code)
        
        print(f"Translated {os.path.basename(input_file)} to {language_name} and saved to {output_file}")

def main():
    input_file = r'..\src\Locales\enUS.lua'
    output_folder = r'.\Translated'

    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    process_file(input_file, output_folder)

if __name__ == "__main__":
    main()

