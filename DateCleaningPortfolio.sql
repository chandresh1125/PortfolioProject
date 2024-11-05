/* 
	Cleaning Data in SQL
*/

SELECT *
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


-- Standerdize date format

CONVERT(data_type(length), expression, style)

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing 

SELECT SaleDate, CAST(SaleDate as Date)
FROM NashvilleHousing 


UPDATE [NashvilleHousing] SET SaleDate=CONVERT(Date, SaleDate)			 -- Didnt work

ALTER TABLE [NashvilleHousing] 
ADD SaleDateConverted date												   -- Add new column

UPDATE [NashvilleHousing] SET SaleDateConverted=CONVERT(Date, SaleDate)		-- It worked



-- Populate property address data

SELECT * from [NashvilleHousing]
WHERE PropertyAddress is null
--ORDER BY ParcelID desc


SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
FROM [NashvilleHousing] a
JOIN [NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL


SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [NashvilleHousing] a
JOIN [NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [NashvilleHousing] a
JOIN [NashvilleHousing] b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL



--- Breaking out address into Indivisual column (Address, City, State)

SELECT PropertyAddress
  FROM [PortfolioProject].[dbo].[NashvilleHousing]


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [NashvilleHousing]



ALTER TABLE [NashvilleHousing]
ADD PropertySplitAddress nvarchar(255); 

ALTER TABLE [NashvilleHousing]
ADD PropertySplitCity nvarchar(255); 

UPDATE [NashvilleHousing] SET
PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE [NashvilleHousing] SET
PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT * FROM [NashvilleHousing]


--- 

SELECT OwnerAddress 
FROM NashvilleHousing

SELECT 
PARSENAME(OwnerAddress,1)                          -- PARSENAME only work with period(.)
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE [NashvilleHousing]
ADD OwnerSplitAddress nvarchar(255); 

ALTER TABLE [NashvilleHousing]
ADD OwnerSplitCity nvarchar(255); 

ALTER TABLE [NashvilleHousing]
ADD OwnerSplitState nvarchar(255); 

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1);


SELECT * 
FROM NashvilleHousing


--- Change 'Y' and 'N' to 'Yes' and 'No'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing 
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID)
	row_num
FROM NashvilleHousing 
--ORDER BY ParcelID
)
SELECT * FROM RowNumCTE
WHERE row_num > 1



WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER ( 
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
	ORDER BY UniqueID)
	row_num
FROM NashvilleHousing 
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


---- Delete Unused Column

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate