function! ToggleHeader()
python << endpython

import vim
import os.path

# These lists can be modified to meet your requirements.
src_file_extensions = [".cpp", ".c", ".cc"]
inc_file_extensions = [".hpp", ".h"]

# It is important to keep the / to make sure that it is actually a folder and
# not part of any filename.
# It is possible to specify multiple names here!
src_folder_names = ["/src/", "/source/"]
inc_folder_names = ["/include/", "/inc/"]

name = vim.current.buffer.name



def make_dest_base_names(base_name, from_folder_parts, dest_folder_parts):
  """
  This function takes a base name and find the part that must be replaced.
  If this part has been found, it replaces it by the possible destination folder
  parts and returns a list of possible new base folder names.
  Note that the given base name itself is also a possible destination base name.
  This happens when the source and header files are kept in the same directory.
  """
  dest_base_names = [base_name]
  for from_folder_part in from_folder_parts:
    pos = base_name.rfind(from_folder_part)
    if pos > 0:
      for dest_folder_part in dest_folder_parts:
        new_base_file = base_name[:pos] + \
                        dest_folder_part + \
                        base_name[pos+len(from_folder_part):len(base_name)]
        dest_base_names.append(new_base_file)
  return dest_base_names



def toggle_file(base_names, extensions):
  """
  This function tries all possible combinations of base names and extensions.
  It switches to the first matching file.
  """
  for base_name in base_names:
    for extension in extensions:
      file_name = base_name + extension
      if os.path.isfile(file_name):
        vim.command('e ' + file_name)
        return True
  return False


# Split the name into the base name and the extension.
# The dot will be part of the extension.
dot_pos = name.rfind('.')
base_name = name[:dot_pos]
extension = name[dot_pos:len(name)]

# Check to which group (src or include) the file belongs.
# Switch accordingly.
successful = False
if extension in src_file_extensions:
  dest_base_names = make_dest_base_names(base_name,
                                         src_folder_names,
                                         inc_folder_names)
  successful = toggle_file(dest_base_names, inc_file_extensions)
elif extension in inc_file_extensions:
  dest_base_names = make_dest_base_names(base_name,
                                         inc_folder_names,
                                         src_folder_names)
  successful = toggle_file(dest_base_names, src_file_extensions)
else:
  pass

if not successful:
  print "ToggleHeader found no matching file for:", name

vim.command("return 1")
endpython
endfunction
