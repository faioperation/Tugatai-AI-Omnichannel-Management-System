import re

with open('lib/features/Orderbooking/widget/create_order_dialog.dart', 'r') as f:
    content = f.read()

def replace_textfield(match):
    label = match.group(1)
    controller = match.group(2)
    hint = match.group(3)
    
    return f'''Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('{label}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
    const SizedBox(height: 8),
    CustomTextfield(controller: {controller}, hintText: '{hint}'),
  ],
)'''

# Regex to match CustomTextField(label: '...', controller: _ctrl, hint: '...')
content = re.sub(r"CustomTextField\(\s*label:\s*'([^']+)',\s*controller:\s*([a-zA-Z0-9_]+),\s*hint:\s*'([^']+)'\s*\)", replace_textfield, content)

with open('lib/features/Orderbooking/widget/create_order_dialog.dart', 'w') as f:
    f.write(content)

