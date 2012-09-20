README File for Mastering UNIX Shell Scripting - Second Edition

Author: Randal K. Michael

========
Publisher's note:  Please note when downloading the compressed 
files from our website, some versions of IE may rename the file.
If your browser renames the archive file, please make sure you 
change the name  back before extracting the original files
from the archive.
========


The Mastering_UNIX_SS.tar.Z and Mastering_UNIX_SS.tar.gz files
are compressed tar archives that contain sample code from the 
second edition of Mastering UNIX Shell Scripting. Please note 
that there is an errata (a description of an error in the book's 
edited code) posted in the next paragraph, followed by some notes. 
Please be assured that the shell scripts and functions in this
package were never affected by the mistake in the book's edited
code pertaining to the word "Bash".

I hope you gain some knowledge from this book, shell scripts,
and the set of functions packaged here.

ERRATA:

(This is the errata for the first 4,000 copies of this book.)

During the course of editing this book, a global search-and-replace was
conducted that changed all instances of "bash" to "Bash" in the code.
Given that UNIX is case-sensitive, references in the code should be to
"bash". Note that all the original code available at the Downloads tab
of this page was never affected.

The result was limited to the first line of Bash shell scripts, 
defined as:

#!/bin/Bash

Instead, the correct declaration should be:

#!/bin/bash

In the book you may also see some Bash shell script filenames 
incorrectly named with a ".Bash" filename extension instead of
the correct ".bash" filename extension. 

For example, the filename:

my_shell_script.Bash

should actually be:

my_shell_script.bash

Thanks for your understanding.


AUTHOR NOTES:

I) Extracting the shell scripts and functions to your system:

The Mastering_UNIX_SS.tar.Z and Mastering_UNIX_SS.tar.gz files
are compressed tar archives of the shell scripts and functions 
in the book, and some extras in a few areas. When you extract 
this archive, you will see chapter directories that contain the 
code in each chapter in the book that has downloadable code. 
For example, when you untar the archive, the following 
subdirectories will be created (assuming you have the file 
permissions, that is).

chapter1
chapter2
chapter4
chapter5

Notice there is not a "chapter3" subdirectory. This is because there
is no downloadable code in this chapter.

To extract the archive, first create a directory, or just change 
the directory to where you want extract the archive. 

Option 1: Extracting the compressed Mastering_UNIX_SS.tar.Z archive.

Copy the Mastering_UNIX_SS.tar.Z file to your desired top-level 
directory, and then execute the following commands.

The following uncompress command will uncompress the archive image file:

       uncompress ./Mastering_UNIX_SS.tar.Z

The following tar command will untar the archive image file to the
current directory:

       tar -xvpf ./Mastering_UNIX_SS.tar

Option 2: Extracting the gzipped Mastering_UNIX_SS.tar.gz archive.

Copy the Mastering_UNIX_SS.tar.gz file to your desired top-level 
directory, and then execute the following commands.

The following gunzip command will uncompress the archive image file:

       gunzip ./Mastering_UNIX_SS.tar.gz

The following tar command will untar the archive image file to the
current directory:

       tar -xvpf ./Mastering_UNIX_SS.tar

Both archives contain the same information.

II) Using the echo command in Bash shell:

The echo command executes differently depending on the UNIX
shell you are executing it in. A specific situation is using the
echo command's backslash operators, such as:

echo "\n"  # To produce a newline

echo "\c"  # To continue on the same line without a
           # carriage return or line feed

and many others.

Of all the methods covered in this book to properly use the
echo command when Bash shell is involved, the most reliable
method is aliasing the echo command for use in a Bash shell
environment. Many Korn shell scripts will execute in a default
Bash shell if /bin/ksh is not installed.

By adding the following case statement to the top of your code, it 
will not be necessary to use echo -e when dealing with the echo 
command's backslash operators if your ksh script should happen
to execute in a Bash shell. This is common on many Linux systems.
You can also use this in your Bash scripts if you want to omit
adding the -e to your echo statement when writing your shell scripts.

case $(basename $SHELL) in
bash) alias echo="echo -e"
      ;;
esac

Now anytime the echo command is used in a script that is 
executing in Bash shell, echo -e will be substituted,
enabling the backslash operators \n, \c, \t, and so on.

III) How individual functions are separated into individual files:

When this book's script/function archive is installed to your system,
each function that is its own file will have the following filename
format:

"function_" followed by the name of the actual function in the script.

For example:

If the real function name in the script or book is:

check_file_system

Then the filename for this individual function would be:

function_check_file_system

----

Thanks for buying my book. I hope the answer to every scripting problem
you encounter will be intuitively obvious when you finish
reading this second edition!


Cheers,

Randy

