prepare Q1(character) as
select count(*) as wins from matches m
	where (m.hteam=$1 and m.hscore>m.vscore) or (m.vteam=$1 and m.vscore>m.hscore);

Execute Q1('A1');