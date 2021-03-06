{BufferedProcess} = require 'atom'

module.exports =
  activate: ->
    atom.workspaceView.command "execute-as-ruby:execute", => @execute()

  execute: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.activePaneItem
    cursor = editor.getCursor()
    selection = editor.getSelectedText()

    if not selection
        line = cursor.getCurrentBufferLine()
        @runRuby(line, (result) ->
            editor.moveCursorToEndOfLine()
            if result.indexOf("\n") == -1
                editor.insertText(" # => " + result)
            else
                editor.insertText("\n=begin\n" + result + "\n=end"))
    else
        @runRuby(selection, (result) ->
            editor.moveCursorToEndOfLine()
            editor.insertText(" " + result))

  packagePath: ->
    packagePath = null
    for p in atom.packages.getAvailablePackagePaths()
        if p.indexOf("/execute-as-ruby") != -1
            packagePath = p
    if not packagePath
        throw "Could not locate package path"
    packagePath

  runRuby: (rubyCode, done) ->
      command = 'ruby'
      args = ['--', @packagePath() + "/lib/helper.rb", rubyCode]
      output = []
      stdout = (data) -> output.push(data)
      exit = (code) -> done(output.join(""))
      stderr = (data) -> output.push(data)
      process = new BufferedProcess({command, args, stdout, stderr, exit})
