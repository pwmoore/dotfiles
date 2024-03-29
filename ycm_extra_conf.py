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
            path = curdir + os.path.sep + '.ycm_project_conf.py'
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
  flags = ['-framework', 'CoreFoundation', '-framework', 'IOKit', '-framework', 'Foundation']
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
  cflags = ['-std=gnu11', '-x', 'c']
  cppflags = ['-std=c++17', '-x', 'c++']
  objcflags = ['-std=gnu11', '-fblocks', '-fobjc-arc', '-fobjc-exceptions', '-fexceptions', '-fobjc-runtime=macosx-10.9.0', '-fencode-extended-block-signature', '-x', 'objective-c']
  objcppflags = ['-std=c++17', '-fblocks', '-fobjc-arc', '-fobjc-exceptions', '-fexceptions', '-fobjc-runtime=macosx-10.9.0', '-fencode-extended-block-signature', '-x', 'objective-c']
  if filetype == 'c':
    return cflags
  elif filetype == 'cpp':
    return cppflags
  elif filetype == 'objc':
    return objcflags
  elif filetype == 'objcpp':
    return objcppflags
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

def GetFileTypeForHeader(filename):
    cppkeywords = ["vector", "unordered_map", "unordered_set", "std::", "class", "namespace", "constexpr", "static_cast", "dynamic_cast", "virtual", "public:", "private:", "protected:", ]
    objckeywords = ["@interface", "@end", "@property", "#import", "NSObject", "NSString", "NSDictionary", "NSArray", "NSData", "Foundation.h"]
    is_cpp = False
    is_objc = False

    with open(filename, "r") as f:
        lines = f.readlines()
    for l in lines:
        for kw in cppkeywords:
            if kw in l:
                is_cpp = True
        for kw in objckeywords:
            if kw in l:
                is_objc = True

    if is_cpp and is_objc:
        return "objcpp"
    if is_cpp:
        return "cpp"
    if is_objc:
        return "objc"
    else:
        return "c"


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

def FindCorrespondingSourceFile( filename ):
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        return replacement_file
  return filename

def FlagsForFile( filename, **kwargs ):

  return {
    'flags': final_flags,
    'do_cache': True
  }

def Settings( **kwargs ):
  global log
  if kwargs[ 'language' ] == 'cfamily':
    # If the file is a header, try to find the corresponding source file and
    # retrieve its flags from the compilation database if using one. This is
    # necessary since compilation databases don't have entries for header files.
    # In addition, use this source file as the translation unit. This makes it
    # possible to jump from a declaration in the header file to its definition
    # in the corresponding source file.
    filename = FindCorrespondingSourceFile( kwargs[ 'filename' ] )

    log = YCMLogger(True)
    data = kwargs['client_data']
    filetype = data['&filetype']
    base_flags = ['-Wall', ]

    if IsHeaderFile(filename):
      filetype = GetFileTypeForHeader(filename)

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
    }
  return {}
