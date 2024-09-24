-- Here we will be exploring the data of lego from rebrickable to provide insights and findings

-- what are the total number of parts per theme
-- creating a view to reduce query time 

--create view dbo.analytics_view as

--select s.set_num,s.name as set_name, s.year,s.theme_id,cast( num_parts as numeric) set_number, t.name theme_name,t.parent_id,p.name as parent_theme_name
--from ..sets s
--left join themes t
--	on s.theme_id = t.id
--left join themes p
--	on p.parent_id = t.id


-- so now to answer the First Question what the total numer of parts per theme

select * from analytics_view;

select theme_name, sum(set_number) total_num_parts
from ..analytics_view
--where parent_theme_name is not null
group by theme_name
order by 2 desc;

--Theme 'Technic' is at the top with 2079663 part followed by "City" and "Educational and Dacta"
-- when the where filter is removed we can still observe the same output.


-- Q2 What is the total number of parts per year 

select year, sum(set_number) total_num_parts
from ..analytics_view
where parent_theme_name is not null
group by year
order by 2 desc;

--We can see 2024(748631) has the highest number of parts produced then 2023(672188) and 2022(529510) also we can see an exponsial growth in the numbber of parts produced over the last 10years 
-- adding the where clause we can see the gaps in the total number of part of 2024 and 2023 reduces by 100,000 and as well year 2021(338159) has more parts produced compared to 2022(328454)


-- Q3 How Many set where Created in each Century from the DataSet

select century, count(set_num) total_num_parts
from ..analytics_view
--where parent_theme_name is not null
group by century;

-- 21st century currentyly has 47326 sets made where the 20th had just 8166 which the technological growth could be held accountable for teh diversity
-- adding the parent theme name we can still see a large gap in the difference of the same corelation 



-- What percentage of Set Release in the 21st  century were 'Gear' Themed

with cte as 
(
select century, theme_name, count(set_num) total_set_num
from analytics_view 
where century = '21st century'
group by century, theme_name
)
	select *
	from 
	   (
		select century, theme_name,total_set_num, sum(total_set_num) over() as total, (1.00 * total_set_num/sum(total_set_num) over())*100 percentage
		from cte
		--order by 5 desc
		) main
	where lower(theme_name) like '%gear%' -- here we can switch between any of the theme name to see the percentage of set released
-- for gear in the 21st century the set created covered 29.4933017791400 percent of total sets



-- Q5 what is the most popular theme by year in terms of sets released 
select year, theme_name, total_set_num
from

(
select year, theme_name, count(set_num) total_set_num, ROW_NUMBER() over (partition by year order by count(set_num) desc ) roww
from analytics_view 
where century = '21st century'
	--and parent_theme_name is not null 
group by year, theme_name
--order by 1 desc
) m

where roww = 1
order by year desc;

-- here we see that gear is the most popular theme by year for sets released which also verifies the amount of sets released 


-- Q6 What the most produced colors in term of quatity of part 
select color_name, rgb, sum(quantity) as quantity_of_parts
from


(
select color_id, rgb, ip.inventory_id, ip.part_num, ip.quantity, ip.is_spare,c.name color_name, p.name,p.part_material,pc.name catergory_name

from inventory_parts ip
inner join colors c
on ip.color_id =c.id
inner join parts p
on ip.part_num = p.part_num
inner join part_categories pc
on part_cat_id = pc.id
) cc

group by color_name,rgb
order by 3 desc

-- the most produced color is black, followed by "Light Bluish Gray" and then "white"