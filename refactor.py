import os
import re

replacements = [
    'bg', 'bgDeep', 'card', 'primary', 'primaryLight', 'primaryDark',
    'accent', 'teal', 'seafoam', 'seafoamLight', 'warning', 'danger',
    'success', 'text', 'muted', 'mutedLight', 'soft', 'softLight',
    'primaryGradient', 'headerGradient', 'splashGradient'
]

pattern = re.compile(r'AppTheme\.(' + '|'.join(replacements) + r')')

def process_file(filepath):
    if "app_theme.dart" in filepath or "main.dart" in filepath:
        return
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = pattern.sub(r'context.colors.\1', content)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Refactored: {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
