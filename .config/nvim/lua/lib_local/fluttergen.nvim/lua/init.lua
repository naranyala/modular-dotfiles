local M = {}

-- Templates
local function stateless_template(name)
  return string.format([[
import 'package:flutter/material.dart';

class %s extends StatelessWidget {
  const %s({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('%s')),
    );
  }
}
]], name, name, name)
end

local function stateful_template(name)
  return string.format([[
import 'package:flutter/material.dart';

class %s extends StatefulWidget {
  const %s({super.key});

  @override
  State<%s> createState() => _%sState();
}

class _%sState extends State<%s> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('%s')),
    );
  }
}
]], name, name, name, name, name, name, name)
end

local function consumer_template(name)
  return string.format([[
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class %s extends ConsumerWidget {
  const %s({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(child: Text('%s')),
    );
  }
}
]], name, name, name)
end

local function hook_template(name)
  return string.format([[
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class %s extends HookWidget {
  const %s({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: \${counter.value}'),
            ElevatedButton(
              onPressed: () => counter.value++,
              child: const Text('Increment'),
            )
          ],
        ),
      ),
    );
  }
}
]], name, name)
end

local function page_template(name)
  return string.format([[
import 'package:flutter/material.dart';

class %s extends StatelessWidget {
  const %s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('%s')),
      body: const Center(child: Text('%s page')),
    );
  }
}
]], name, name, name, name)
end

local function painter_template(name)
  return string.format([[
import 'package:flutter/material.dart';

class %s extends StatelessWidget {
  const %s({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        size: Size.infinite,
        painter: _%sPainter(),
      ),
    );
  }
}

class _%sPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;
    canvas.drawCircle(size.center(Offset.zero), 50, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
]], name, name, name, name)
end

-- Dispatcher
local templates = {
  stateless = stateless_template,
  stateful = stateful_template,
  consumer = consumer_template,
  hook = hook_template,
  page = page_template,
  painter = painter_template
}

function M.generate_widget(name, widget_type)
  if not name or name == "" then
    print("❌ Please provide a widget name")
    return
  end

  local template_fn = templates[widget_type] or stateless_template
  local content = template_fn(name)

  local file_path = "lib/" .. name .. ".dart"
  local file = io.open(file_path, "w")
  if file then
    file:write(content)
    file:close()
    print("✅ " .. widget_type .. " widget " .. name .. " created at " .. file_path)
    vim.cmd("edit " .. file_path)
  else
    print("❌ Failed to create file")
  end
end

vim.api.nvim_create_user_command('FlutterWidget', function(opts)
  local args = opts.fargs
  M.generate_widget(args[1], args[2] or "stateless")
end, { nargs = "+" })

return M

-- :FlutterWidget HomePage page
-- :FlutterWidget Counter hook
-- :FlutterWidget MyPainter painter
-- :FlutterWidget Profile consumer
--
