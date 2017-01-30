import os
import imp
import platform
import ycm_core
import subprocess

class YCMLogger:
  def __init__(self, debug=False, logfile='/tmp/ycm.log'):
    if os.path.exists(logfile):
      os.unlink(logfile)
    if debug == True:
      self.fd = open(logfile, 'w')
    self.debug = debug
  def write(self, msg):
    if self.debug == True:
      self.fd.write(msg + '\n')
  def close(self):
    if self.debug == True:
      self.fd.close()

log = None

def get_project_conf(flags):
	home = os.environ['HOME']
	curdir = os.getcwd()
	log.write('Starting search for project conf')
	while curdir != home:
		log.write('Searching %s' % curdir)
		files = os.listdir(curdir)
		if '.ycm_project_conf.py' in files:
			path = os.getcwd() + os.path.sep + '.ycm_project_conf.py'
			log.write('Found project conf %s' % path)
			mod = imp.load_source('project_conf', path)
			import project_conf
			log.write('Loaded project_conf')
			return mod.get_project_conf(flags, log)
		parent = os.path.abspath(curdir + os.path.sep + os.pardir)
		log.write('Moving up to %s' % parent)
		curdir = parent
	return flags

def get_darwin_flags():
  global log
  flags = ['-framework', 'CoreFoundation', '-framework', 'IOKit', '-framework', 'Foundation', '-framework', 'SDL2', '-I', '/Library/Frameworks/SDL2.framework/Headers/']
  # p = subprocess.Popen(['xcrun', '--sdk', 'macosx', '--show-sdk-path'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  # out,err = p.communicate('')
  # sdk_path = out.strip()
  # log.write('Got sdk_path=%s' % sdk_path) 
  # fw_path = sdk_path + '/System/Library/Frameworks'
  # frameworks = os.listdir(fw_path)
  # log.write('Got framework path=%s' % fw_path)
  # for fw in frameworks:
  #   fwname = fw.replace('.framework', '')
  #   fwhdr = fw_path + '/%s/Headers' % fw
  #   flags.append('-framework')
  #   flags.append(fwname)
  #   flags.append('-I')
  #   flags.append(fwhdr)
  #   log.write('Added framework %s' % fwname)
  return flags

def get_platform_flags():
  global log
  osname = platform.platform().split('-')[0]
  if osname == 'Darwin':
    log.write('This is Darwin')
    return get_darwin_flags()
  else:
    return []

def get_lang_flags(filetype):
  cflags = ['-std=gnu11', '-x', '-c']
  cppflags = ['-std=c++11', '-x', 'c++']
  objcflags = ['-std=gnu11', '-fblocks', '-fobjc-arc', '-fobjc-exceptions', '-fexceptions', '-fobjc-runtime=macosx-10.9.0', '-fencode-extended-block-signature', '-x', 'objective-c']
  if filetype == 'c':
    return cflags
  elif filetype == 'cpp':
    return cppflags
  elif filetype == 'objc':
    return objcflags
  else:
    return []



# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# You can get CMake to generate this file for you by adding:
#   set( CMAKE_EXPORT_COMPILE_COMMANDS 1 )
# to your CMakeLists.txt file.
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags. Notice that YCM itself uses that approach.
compilation_database_folder = ''

if os.path.exists( compilation_database_folder ):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )


def MakeRelativePathsInFlagsAbsolute( flags, working_directory ):
  if not working_directory:
    return list( flags )
  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
  for flag in flags:
    new_flag = flag

    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith( '/' ):
        new_flag = os.path.join( working_directory, flag )

    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break

      if flag.startswith( path_flag ):
        path = flag[ len( path_flag ): ]
        new_flag = path_flag + os.path.join( working_directory, path )
        break

    if new_flag:
      new_flags.append( new_flag )
  return new_flags


def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]


def GetCompilationInfoForFile( filename ):
  # The compilation_commands.json file generated by CMake does not have entries
  # for header files. So we do our best by asking the db for flags for a
  # corresponding source file, if any. If one exists, the flags for that file
  # should be good enough.
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file )
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile( filename )


def FlagsForFile( filename, **kwargs ):
  global log
  base_flags = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-pedantic',
    '-I',
    '.',
    '-I',
    '/usr/local/include',
	'-I',
	'/usr/include'
  ]
  log = YCMLogger(debug=True)
  data = kwargs['client_data']
  filetype = data['&filetype']
  filetype_flags = get_lang_flags(filetype)
  log.write('Got filetype flags')

  platform_flags = get_platform_flags()
  log.write('Got platform flags')
  flags = base_flags + filetype_flags + platform_flags
  flags = get_project_conf(flags)

  relative_to = DirectoryOfThisScript()
  final_flags = MakeRelativePathsInFlagsAbsolute( flags, relative_to )
  for f in final_flags:
    log.write(f)

  return {
    'flags': final_flags,
    'do_cache': True
  }
