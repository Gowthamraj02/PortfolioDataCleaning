/* Cleaning Data Using SQL Queries*/
select * from GowthamrajPortfolio..HousingNashville

--Standardizing Date

select SaleDate, convert(date,saledate) as SaleDateStd from GowthamrajPortfolio..HousingNashville

update HousingNashville
set SaleDate = CONVERT(date,saledate)  --Using UPDATE it works mostly but now it didnt work so lets go with ALTER

select SaleDateStandardized from GowthamrajPortfolio..HousingNashville

alter table HousingNashville
add SaleDateStandardized Date

update HousingNashville
set SaleDateStandardized = CONVERT(date,saledate)

--Populating possible null values

select * from GowthamrajPortfolio..HousingNashville
select UniqueID, parcelid,propertyaddress from HousingNashville
where PropertyAddress is not null

select a.parcelid, a.propertyaddress,b.parcelid, b.PropertyAddress --//viewing just possible outcome data
from GowthamrajPortfolio..HousingNashville a
join GowthamrajPortfolio..HousingNashville b   -- we use join to replace null values 
	on a.ParcelID = b.ParcelID				   -- assuming similar parcelid has same propertyaddress
	and a.[UniqueID ] <> b.[UniqueID ]		   -- unique id is different but parcelid will have same numbers
where a.PropertyAddress is null

select a.parcelid, a.propertyaddress,b.parcelid, b.PropertyAddress, --//adding data column using previous step 
isnull(a.propertyaddress,b.propertyaddress) as PopulatedAddress
from GowthamrajPortfolio..HousingNashville a
join GowthamrajPortfolio..HousingNashville b   -- we use join to replace null values 
	on a.ParcelID = b.ParcelID				   -- assuming similar parcelid has same propertyaddress
	and a.[UniqueID ] <> b.[UniqueID ]		   -- unique id is different but parcelid will have same numbers
where a.PropertyAddress is null					-- this null values cant be seen after update command

update a								-- update the existing column null values, we can see null after this
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from GowthamrajPortfolio..HousingNashville a
join GowthamrajPortfolio..HousingNashville b   -- we use join to replace null values 
	on a.ParcelID = b.ParcelID				   -- assuming similar parcelid has same propertyaddress
	and a.[UniqueID ] <> b.[UniqueID ]		   -- unique id is different but parcelid will have same numbers
where a.PropertyAddress is null

--Separating address into individual columns(street,city)
select PropertyAddress from HousingNashville
--where PropertyAddress is null
--order by ParcelID

--using substring to split with ',' as delimiter
select 
SUBSTRING(propertyaddress, 1, charindex(',',propertyaddress) -1) as PropertyStr_address, --/+1/-1 is used to hide","in o/p
SUBSTRING(propertyaddress, charindex(',',propertyaddress) +1, len(propertyaddress)) as PropertyCity_address 
from HousingNashville

alter table housingnashville add PropertyStr_address nvarchar(255)
update HousingNashville set PropertyStr_address = SUBSTRING(propertyaddress, 1, charindex(',',propertyaddress) -1)

alter table housingnashville add PropertyCity_address nvarchar(255)
update HousingNashville set PropertyCity_address = SUBSTRING(propertyaddress, charindex(',',propertyaddress) +1, len(propertyaddress))

--//Another way to do this separation
select * from HousingNashville

select												--Parsename will take from end to first. so 3 is 1 output
PARSENAME(replace(owneraddress,',','.'),3) as OwnerStrAdd, --Parsename will only separate where '.' is delimitter
PARSENAME(replace(owneraddress,',','.'),2) as OwnerCityAdd,--so we use replace to convert ',' to '.'
PARSENAME(replace(owneraddress,',','.'),1) as OwnerStateAdd from HousingNashville

where OwnerAddress is not null

--Now let's add this as separate column into the table
alter table housingnashville
add OwnStrAdd nvarchar(255)

update HousingNashville 
set ownstradd = PARSENAME(replace(owneraddress,',','.'),3)


alter table housingnashville
add OwnCityAdd nvarchar(255)

update HousingNashville 
set owncityadd = PARSENAME(replace(owneraddress,',','.'),2)

alter table housingnashville
add OwnStateAdd nvarchar(255)

update HousingNashville 
set ownstateadd = PARSENAME(replace(owneraddress,',','.'),1)

select * from HousingNashville


-- changing abbreviations like Y / Yes or N/No

select soldasvacant from HousingNashville

select distinct(soldasvacant), count(soldasvacant) from HousingNashville
group by SoldAsVacant
order by 2

select distinct(soldasvacant), count(soldasvacant),
case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant 
	end 
from HousingNashville
group by SoldAsVacant
order by 2

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant 
	end 
from HousingNashville

update HousingNashville 
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else soldasvacant 
	end 

--//Viewing and removing duplicate values
with RownumCTE as (
select *, ROW_NUMBER() over(partition by Parcelid,
										 propertyaddress,
										 saleprice,
										 saledate,
										 legalreference  order by uniqueid) rownum
from HousingNashville)         --//This will show us the duplicates as 2/3/4.. in rownum column

--select * from RownumCTE
--where rownum > 1		  --//whereever rownum >1 it can be seen in output
--order by PropertyAddress  --// we can view duplicate values now, once we run delete it'll be gone.

delete from RownumCTE
where rownum > 1

--//Removing useless columns

select * from HousingNashville

alter table housingnashville
drop column owneraddress




