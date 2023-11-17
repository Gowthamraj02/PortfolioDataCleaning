/* Cleaning Data Using SQL Queries*/
SELECT * FROM GowthamrajPortfolio..HousingNashville

--StANDardizing Date

SELECT SaleDate, cONvert(date,saledate) AS SaleDateStd FROM GowthamrajPortfolio..HousingNashville

UPDATE HousingNashville
SET SaleDate = CONVERT(date,saledate)  --Using UPDATE it works mostly but now it didnt work so lets go WITH ALTER

SELECT SaleDateStANDardized FROM GowthamrajPortfolio..HousingNashville

ALTER TABLE HousingNashville
ADD SaleDateStANDardized Date

UPDATE HousingNashville
SET SaleDateStANDardized = CONVERT(date,saledate)

--Populating possible NULL values

SELECT * FROM GowthamrajPortfolio..HousingNashville
SELECT UniqueID, parcelid,propertyADDress FROM HousingNashville
WHERE PropertyAddress IS NOT NULL

SELECT a.parcelid, a.propertyADDress,b.parcelid, b.PropertyAddress --//viewing just possible outcome data
FROM GowthamrajPortfolio..HousingNashville a
JOIN GowthamrajPortfolio..HousingNashville b   -- we use JOIN to replace NULL values 
	ON a.ParcelID = b.ParcelID				   -- assuming similar parcelid has same propertyADDress
	AND a.[UniqueID ] <> b.[UniqueID ]		   -- unique id IS different but parcelid will have same numbers
WHERE a.PropertyAddress IS NULL

SELECT a.parcelid, a.propertyADDress,b.parcelid, b.PropertyAddress, --//ADDing data column using previous step 
ISNULL(a.propertyADDress,b.propertyADDress) AS PopulatedAddress
FROM GowthamrajPortfolio..HousingNashville a
JOIN GowthamrajPortfolio..HousingNashville b   -- we use JOIN to replace NULL values 
	ON a.ParcelID = b.ParcelID				   -- assuming similar parcelid has same propertyADDress
	AND a.[UniqueID ] <> b.[UniqueID ]		   -- unique id IS different but parcelid will have same numbers
WHERE a.PropertyAddress IS NULL					-- thIS NULL values cant be seen after UPDATE commAND

UPDATE a								-- UPDATE the exISting column NULL values, we can see NULL after thIS
SET propertyADDress = ISNULL(a.propertyADDress,b.propertyADDress)
FROM GowthamrajPortfolio..HousingNashville a
JOIN GowthamrajPortfolio..HousingNashville b   -- we use JOIN to replace NULL values 
	ON a.ParcelID = b.ParcelID				   -- assuming similar parcelid has same propertyADDress
	AND a.[UniqueID ] <> b.[UniqueID ]		   -- unique id IS different but parcelid will have same numbers
WHERE a.PropertyAddress IS NULL

--Separating ADDress into individual columns(street,city)
SELECT PropertyAddress FROM HousingNashville
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

--using substring to split WITH ',' AS delimiter
SELECT 
SUBSTRING(propertyADDress, 1, charindex(',',propertyADDress) -1) AS PropertyStr_ADDress, --/+1/-1 IS used to hide","in o/p
SUBSTRING(propertyADDress, charindex(',',propertyADDress) +1, len(propertyADDress)) AS PropertyCity_ADDress 
FROM HousingNashville

ALTER TABLE housingnashville ADD PropertyStr_ADDress nvarchar(255)
UPDATE HousingNashville SET PropertyStr_ADDress = SUBSTRING(propertyADDress, 1, charindex(',',propertyADDress) -1)

ALTER TABLE housingnashville ADD PropertyCity_ADDress nvarchar(255)
UPDATE HousingNashville SET PropertyCity_ADDress = SUBSTRING(propertyADDress, charindex(',',propertyADDress) +1, len(propertyADDress))

--//ANOTher way to do thIS separatiON
SELECT * FROM HousingNashville

SELECT												--Parsename will take FROM END to first. so 3 IS 1 output
PARSENAME(replace(ownerADDress,',','.'),3) AS OwnerStrAdd, --Parsename will ONly separate WHERE '.' IS delimitter
PARSENAME(replace(ownerADDress,',','.'),2) AS OwnerCityAdd,--so we use replace to cONvert ',' to '.'
PARSENAME(replace(ownerADDress,',','.'),1) AS OwnerStateAdd FROM HousingNashville

WHERE OwnerAddress IS NOT NULL

--Now let's ADD thIS AS separate column into the TABLE
ALTER TABLE housingnashville
ADD OwnStrAdd nvarchar(255)

UPDATE HousingNashville 
SET ownstrADD = PARSENAME(replace(ownerADDress,',','.'),3)


ALTER TABLE housingnashville
ADD OwnCityAdd nvarchar(255)

UPDATE HousingNashville 
SET owncityADD = PARSENAME(replace(ownerADDress,',','.'),2)

ALTER TABLE housingnashville
ADD OwnStateAdd nvarchar(255)

UPDATE HousingNashville 
SET ownstateADD = PARSENAME(replace(ownerADDress,',','.'),1)

SELECT * FROM HousingNashville


-- changing abbreviatiONs like Y / Yes or N/No

SELECT soldasvacant FROM HousingNashville

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant) FROM HousingNashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT DISTINCT(soldasvacant), COUNT(soldasvacant),
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant 
	END 
FROM HousingNashville
GROUP BY SoldAsVacant
ORDER BY 2

SELECT soldasvacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant 
	END 
FROM HousingNashville

UPDATE HousingNashville 
SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
	WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant 
	END 

--//Viewing AND removing duplicate values
WITH RownumCTE AS (
SELECT *, ROW_NUMBER() over(partitiON by Parcelid,
propertyADDress, saleprice, saledate, legalreference  ORDER BY uniqueid) rownum
FROM HousingNashville)         --//ThIS will show us the duplicates AS 2/3/4.. in rownum column

--SELECT * FROM RownumCTE
--WHERE rownum > 1		  --//WHEREever rownum >1 it can be seen in output
--ORDER BY PropertyAddress  --// we can view duplicate values now, ONce we run delete it'll be gONe.

delete FROM RownumCTE
WHERE rownum > 1

--//Removing useless columns

SELECT * FROM HousingNashville

ALTER TABLE housingnashville
DROP column ownerADDress




