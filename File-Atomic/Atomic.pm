package ActiveState::File::Atomic;

use strict;
use base qw(DynaLoader);

our $VERSION = '1.01';

ActiveState::File::Atomic->bootstrap($VERSION);

sub tempfile {
    my $o = shift;
    my $tmpfile = $o->_tempfile;
    open (my $FH, ">", $tmpfile) or die "can't write to $tmpfile: $!";
    return $FH;
}

sub commit_file {
    my ($o, $file) = @_;
    open (my $FH, "<", $file) or die "can't open $file for read: $!";
    $o->commit_fd(fileno $FH);
    close $FH;
}

1;

=head1 NAME

ActiveState::File::Atomic - edit files atomically with locking

=head1 SYNOPSIS

   use ActiveState::File::Atomic;
   my $at = ActiveState::File::Atomic->new($filename, writable => 1);

   # For small files:
   (my $contents = $at->slurp) =~ s/foo/bar/g;
   $at->commit_string($contents);

   # For larger files:
   my $wfh = $at->tempfile;
   while (defined($_ = $at->readline))) {
       s/foo/bar/g;
       print $wfh $_;
   }
   close($wfh);
   $at->commit_tempfile;

   # If you have your own file:
   $at->commit_file($myfile);

=head1 DESCRIPTION

ActiveState::File::Atomic makes it easier to write code that modifies files
safely. It always uses locking, making it safe for concurrent access. It also
handles writing backup files; either simple ".bak" files, or a configurable
number of numbered backups, inspired by the logrotate(1) utility.

ActiveState::File::Atomic provides the following methods:

=over 4

=item new()

    $file = ActiveState::File::Atomic->new($file, %opts);

Creates a new object, opening the C<$file> in either read-only or
read/write mode and locking it.  If the file can not be opened or the
lock on it not obtained then the constuctor will croak.

Options are passed as key/value pairs after the filename.  The
supported options are:

=over 4

=item writable

A boolean. If true, the file is opened read/write, and you can call the
write_handle(), revert(), and commit() methods. If not, the file is opened
read-only, and these methods will croak if you try to use them.

=item create

A boolean. If true, and writable is also true, the file is created if
it does not already exist.  Note that the file will be created when
the ActiveState::File::Atomic object is created, so it will end up
existing and empty even if commit is not called.

=item nolock

A boolean. If true, and neither 'create' nor 'writable' is also true, the file
is opened without locking. This is safe because file updates happen
atomically. It can lead to inconsistent data being read when multiple files
are being updated at once, so this option should only be used for systems
which only read a single file (or where data from multiple files are
independent).

=item timeout

A number representing seconds. Normally ActiveState::File::Atomic will
wait forever trying to acquire a lock on the file. You can specify how
long to wait with this option.  The constructor will croak if it times
out waiting for the lock.

=item backup_ext

A string. If specified, a backup file will be created when you call the commit()
method. The backup file will be named the same thing as the original file with
C<backup_ext> appended.

=item rotate

A number.  If specified, C<rotate> backups will be kept. The files are
named as the original file with C<backup_ext> and the current rotation
number appended. If you didn't specify C<backup_ext>, the string C<.>
is used. To simply append the rotation number, specify an empty
C<backup_ext>. Rotation numbers are always left-padded with zeros if
C<rotate> is specified as 10 or greater.  This ensures that the files
sort correctly.

=back

=item slurp()

"Slurps" the entire contents of the file into a string, and returns it.

This method croaks on failure.

=item readline()

Returns a single line from the input $file, or C<undef> on EOF. Use this to
iterate through a large file.

This method croaks on failure.

=item commit_string()

   $at->commit_string($contents)

Commits C<$contents> to the file. Internally, this creates a temporary file
and writes C<$contents> to it. The temporary file is atomically renamed to the
original file. Backup files are created according to the settings of
C<backup_ext> and C<rotate>.  The method will croak on failure or if the
C<writable> option was not passed to the constructor.

Calling commit_string() implies close(). You should not call any other method
on the object after calling commit_string().

=item commit_file()

   $at->commit_file($filename)

Commits the contents of C<$filename> to the file. Internally, this copies the
contents of C<$filename> to the temporary file. The temporary file is
atomically renamed to the original file. Backup files are created according to
the settings of C<backup_ext> and C<rotate>.  The method will croak on failure
or if the C<writable> option was not passed to the constructor.

Calling commit_file() implies close(). You should not call any other method
on the object after calling commit_file().

=item commit_fd()

   $at->commit_fd(fileno($HANDLE));

Commits the contents of the file underneath C<$HANDLE> to the file.
Internally, this copies from C<$HANDLE> to a temporary file. The temporary
file is atomically renamed to the original file. Backup files are created
according to the settings of C<backup_ext> and C<rotate>.  The method will
croak on failure or if the C<writable> option was not passed to the
constructor.

Calling commit_fd() implies close(). You should not call any other method
on the object after calling commit_fd().

=item tempfile()

   my $wfh = $at->tempfile;

Creates the temporary file and opens it for writing. Using tempfile() and
commit_tempfile() is more efficient than using commit_file() for large files,
because it avoids copying the data to the temporary file.

This method croaks on failure.

=item commit_tempfile()

Commits the contents of the temporary file. The temporary file is atomically
renamed to the original file. Backup files are created according to the
settings of C<backup_ext> and C<rotate>.  The method will croak on failure or
if the C<writable> option was not passed to the constructor.

Calling commit_fd() implies close(). You should not call any other method
on the object after calling commit_fd().

=item close()

Reverts any uncommitted changes and unlocks the file. You should not call any
other methods after calling close().

Normally there is no need to call close() explicitly since the object
destructor will invoke it when the object goes out of scope.

This method can not fail and has no return value.

=back

=head1 COPYRIGHT

Copyright (C) 2002, ActiveState Corporation.
All Rights Reserved.

=cut
