package DBICTestLib;
use strict;
use warnings;

use DBI;

use base 'Exporter';

our @EXPORT_OK = qw/ new_db /;

sub new_db {
    
    if ( -f 't/test.db' ) {
        unlink 't/test.db'
            or die $!;
    }
    
    my $dbh = DBI->connect(
        'dbi:SQLite:dbname=t/test.db',
        {
            RaiseError => 1,
            AutoCommit => 1,
        });
    
    $dbh->do( <<SQL );
CREATE TABLE master (
	id             INTEGER PRIMARY KEY,
	text_col       TEXT,
	password_col   TEXT,
	checkbox_col   TEXT,
	select_col     TEXT,
	radio_col      TEXT,
	radiogroup_col TEXT,
	date_col       DATETIME,
	type           INTEGER,
	type2_id       INTEGER,
	not_in_form    TEXT
);
SQL
    
    $dbh->do( <<SQL );
CREATE TABLE note (
	id     INTEGER PRIMARY KEY,
	master INTEGER,
	note   TEXT
);
SQL
    
    $dbh->do( <<SQL );
CREATE TABLE user (
	id     INTEGER PRIMARY KEY,
	master INTEGER,
	name   TEXT,
	title  TEXT
);
SQL
    
    $dbh->do( <<SQL );
CREATE TABLE band (
	id   INTEGER PRIMARY KEY,
	band TEXT
);
SQL
    
    $dbh->do( <<SQL );
CREATE TABLE user_band (
	user INTEGER,
	band INTEGER,
	PRIMARY KEY (user, band)
);
SQL
    
    $dbh->do( <<SQL );
CREATE TABLE address (
	id        INTEGER PRIMARY KEY,
	user      INTEGER,
	address   TEXT
);
SQL
    
        $dbh->do( <<SQL );
CREATE TABLE type (
	id   INTEGER PRIMARY KEY,
	type TEXT
);
INSERT INTO `type` (`type`) VALUES('foo');
INSERT INTO `type` (`type`) VALUES('bar');
SQL
         $dbh->do( <<SQL );
CREATE TABLE type2 (
	id   INTEGER PRIMARY KEY,
	type TEXT
);
INSERT INTO `type` (`type2`) VALUES('foo');
INSERT INTO `type` (`type2`) VALUES('bar');
SQL
    
}

1;
