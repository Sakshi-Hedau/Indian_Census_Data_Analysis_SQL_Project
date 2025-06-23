
select * from dbo.Data1;
select * from dbo.Data2;

-- no of rows into our dataset

select count(*) from dbo.Data1;
select count(*) from dbo.Data2;

-- dataset for jharkhand and bihar

select * from dbo.Data1 where state in ('Jharkhand', 'Bihar');

-- population of india
select sum(Population) population from dbo.Data2;

-- avg growth 

select AVG(Growth)*100 as Avg_Growth from dbo.Data1;

-- avg growth state wise

select state,AVG(Growth)*100 as avg_growth from dbo.Data1 group by State;

-- avg sex ratio state wise

select state,round(AVG(Sex_Ratio),0) as avg_set_ratio from dbo.Data1 group by State order by avg_set_ratio Desc;

-- avg literacy rate

select state,round(AVG(Literacy),0) as avg_literacy from dbo.Data1 group by State having round(AVG(Literacy),0)>90 order by avg_literacy desc;

-- top 3 state having highest growth ratio

select  top 3 state, avg(growth)*100 as avg_growth from dbo.Data1 group by state order by avg_growth desc;

-- Bottom 3 state having lowest sex ratio

select top 3 state,round(AVG(Sex_Ratio),0) as avg_set_ratio from dbo.Data1 group by State order by avg_set_ratio Asc;

-- top and Bottom 3 state in literacy rate
Drop table if exists #topstate
create table #topstate(
 state nvarchar(255),
 topstate float
 );
 insert into #topstate 
 select state,round(AVG(Literacy),0) as avg_literacy from dbo.Data1 group by State order by avg_literacy desc;

 select top 3 state, topstate from #topstate;

 Drop table if exists #bottomstate
create table #bottomstate(
 state nvarchar(255),
 bottomstate float
 );
 insert into #bottomstate 
 select state,round(AVG(Literacy),0) as avg_literacy from dbo.Data1 group by State order by avg_literacy asc;

 select top 3 state, bottomstate from #bottomstate order by bottomstate;

 -- UNION operator
SELECT * FROM (select top 3 state, topstate from #topstate order by topstate desc)t
UNION
SELECT * FROM (select top 3 state, bottomstate from #bottomstate order by bottomstate asc)b;

-- states starting with letter a or b

select distinct state from dbo.Data1 where LOWER(state) like 'a%' OR LOWER(state) like 'b%';

-- States starting with letter a and ending with letter m

select distinct state from dbo.Data1 where LOWER(state) like 'a%m';

-- Joining Both table

-- total males and females

select d.state, sum(d.Males) Total_Male, sum(d.Females) Total_Female from (select c.district, c.state, Round(c.Population/(c.Sex_Ratio+1),0) Males, Round(c.population*c.sex_ratio/(c.sex_ratio+1),0) Females from (select D1.District, d1.State, d1.Sex_Ratio/1000 as sex_ratio, d2.Population from dbo.Data1 D1 inner join dbo.Data2 D2 on d1.District=d2.District)c)d group by d.State;

-- total literate and illiterate people

select d.state, sum(d.literate), sum(d.illiterate) from (Select c.district, c.State, round(c.literacy_rate*c.Population,0) as literate, round(c.Population*(1- c.literacy_rate),0) as illiterate from (select D1.District, d1.State, d1.Literacy/100 as literacy_rate, d2.Population from dbo.Data1 D1 inner join dbo.Data2 D2 on d1.District=d2.District) c) d group by state;

-- previous census population
select sum(m.previous_census_population) previous_census_population, sum(m.current_population) current_population from 
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_population) current_population from
(select c.state, c.district, c.population as current_population, Round(c.population/(1+c.growth),0) as previous_census_population from (select D1.District, d1.State, d1.growth, d2.Population from dbo.Data1 D1 inner join dbo.Data2 D2 on d1.District=d2.District) c) d group by state) m;

-- Population vs area
select total_area/previous_census_population as previous_census_population_vs_area, total_area/current_population as current_population_vs_area from
(select q.*, r.total_area from
(select '1' as keyy, z.* from
(select sum(m.previous_census_population) previous_census_population, sum(m.current_population) current_population from 
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.current_population) current_population from
(select c.state, c.district, c.population as current_population, Round(c.population/(1+c.growth),0) as previous_census_population from (select D1.District, d1.State, d1.growth, d2.Population from dbo.Data1 D1 inner join dbo.Data2 D2 on d1.District=d2.District) c) d group by state) m)z)q inner join

(select '1' as keyy, n.* from  (select sum(Area_km2) total_area from dbo.Data2) n)r on q.keyy=r.keyy)g;

-- window function
-- top 3 districts from each state with highest literacy rate

select c.state,c.district, c.literacy, c.rankk from (select d1.State, d1.District,  d1.literacy, RANK() over (partition by d1.state order by d1.literacy desc ) rankk from dbo.Data1 D1) c where c.rankk<4;


