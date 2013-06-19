module.exports = (grunt) ->
  grunt.initConfig

    pkg: grunt.file.readJSON('package.json')

    coffee:
      options:
        sourceMap: true
      compile:
        files: [{
          expand: true
          cwd: 'src/'
          src: ['**/*.coffee']
          dest: 'gen/js'
          ext: '.js'
          }]

    handlebars:
      compile:
        files:
          'gen/js/backbone-select2-templates.js': [
            'src/**/*.hbs'
          ]
        options:
          namespace: 'App.Handlebars'
          wrapped: true
          processName: (filename) ->
            filename = filename.replace /src\//, ''
            filename.replace /\.hbs$/, ''

    watch:
      options:
        livereload: true

      coffee:
        files: 'src/**/*.coffee'
        tasks: ['coffee']

      handlebars:
        files: 'src/**/*.hbs'
        tasks: ['handlebars']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-handlebars')

  grunt.registerTask('default', ['coffee', 'handlebars'])
