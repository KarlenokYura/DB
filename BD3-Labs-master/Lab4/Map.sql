
select top 500 ogr_geometry, ogr_geometry.ToString() as WKT, ogr_geometry.STSrid as SRID from WHiring.dbo.[Карта_рельефа]

declare @g geometry = geometry::STGeomFromText('Point(0 0)', 0);
select @g.STBuffer(5), @g.STBuffer(5).ToString() as WKT from WHiring.dbo.[Карта_рельефа]

go
use WHiring;

--3. �����������, ���������� ��� ����������� ������
declare @g1 geometry; 
select @g1 = Point from MAP where Id = 1;
declare @g2 geometry; 
select @g2 = Point from MAP where Id = 2;
select @g1.STIntersects(@g2) as [�����������], @g1.STCrosses(@g2) as [������������], @g1.STContains(@g2) as [�����������];

go
declare @g1 geometry; 
select @g1 = Point from MAP where Id = (select Office_Addr from VACANCY where Id =(select Job from CANDIDATE where Id = 4));
declare @g2 geometry; 
select @g2 = Point from MAP where Id = (select Place from CANDIDATE where Id = 4);
select @g1.STIntersects(@g2) as [�����������], @g1.STCrosses(@g2) as [������������], @g1.STContains(@g2) as [�����������];

--3. ����������
go
declare @g1 geometry; 
select @g1 = Point from MAP where Id = 1;
declare @g2 geometry; 
select @g2 = Point from MAP where Id = 2;
Select @g1.STDistance(@g2) as D;


go
declare @g1 geometry; 
select @g1 = Point from MAP where Id = (select Office_Addr from VACANCY where Id =(select Job from CANDIDATE where Id = 2));
declare @g2 geometry; 
select @g2 = Point from MAP where Id = (select Place from CANDIDATE where Id = 2);
Select @g1.STDistance(@g2) as D;


--6. Change map object
Declare @m geometry = geometry::STGeomFromText('LINESTRING(6 6, 17 17)', 0);
select @m, @m.Reduce(0.5) as Reduced;


