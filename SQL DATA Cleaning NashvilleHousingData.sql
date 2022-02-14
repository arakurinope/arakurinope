SELECT *
FROM PortfolioProjects..NashvilleHousing

--Standardize SaleDate Format

SELECT SaleDateConverted,  CONVERT(Date,SaleDate)
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
 -- this above query failed to update the date format in the SaleDate column
 --adding a new column SaleDateConverted to the table, then update the new column with the UPDATE Function

ALTER TABLE NashvilleHousing
Add SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

--1-Populate Property Address data
--2-owners address might change the property address rarely do
--3-the property address could be populated if i have a refrence point to base it off,to do this I'm using the ParcelID as REF Point
--4-Self Join the Table to itself on the ParcelID and also distingusih it by the UniqueID is not equal to each other
--5 using the ISNULL function to Populate and then update the table


SELECT *
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--4 Self join Table and update

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Addresses into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

--seperating the Property address using the Substring and  charindex function

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as address
FROM PortfolioProjects..NashvilleHousing

--creating two new columns to add the the new addresses

ALTER TABLE NashvilleHousing
Add Property_Address nvarchar(250);

UPDATE NashvilleHousing
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add Property_City nvarchar(250);

UPDATE NashvilleHousing
SET Property_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


--Seperating Owner adrress using the Parsename Function
--replaced the commas in the Address to a period

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProjects..NashvilleHousing

-- creating new columns to add the the new addresses

ALTER TABLE NashvilleHousing
ADD Owner_Home_Address nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Home_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)


ALTER TABLE NashvilleHousing
ADD Owner_City nvarchar(255);

UPDATE NashvilleHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD Owner_State nvarchar(255);

UPDATE NashvilleHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

--Checking the new addess columns

SELECT *
FROM PortfolioProjects..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE  SoldAsVacant
	END
FROM PortfolioProjects..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE  SoldAsVacant
	END


	-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
--1-used the row_number() function to identify rows duplicate rows to be deleted
--2-partioned the data by the things(column headers) that should be unique to each rows
--3-put the whole query in a CTE 
--then qquery off the CTE

WITH RowNumberCTE AS(
SELECT*,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID) row_num
FROM PortfolioProjects..NashvilleHousing)
SELECT *
FROM RowNumberCTE
WHERE row_num > 1
ORDER BY PropertyAddress




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

