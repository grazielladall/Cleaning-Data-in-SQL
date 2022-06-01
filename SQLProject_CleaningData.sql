/* Cleaning Data in SQL Project */

SELECT * 
FROM dbo.NashvilleHousing

-------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------------------
-- Populate Property Address Data

SELECT *
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL;
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM dbo.NashvilleHousing AS a
JOIN dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing AS a
JOIN dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------
-- Breaking out Addres into Individual Columns (Address, City, State)

-- Property Address

SELECT PropertyAddress
FROM dbo.NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
FROM dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));


SELECT * 
FROM dbo.NashvilleHousing;

-- Owner Address

SELECT OwnerAddress
FROM dbo.NashvilleHousing;

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


SELECT * 
FROM dbo.NashvilleHousing;



-------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" column


SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


	----------------------------------------------------------
	-- Remove Duplicates

WITH RowNumCTE AS (
SELECT *,  
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) AS row_num
FROM dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;


SELECT * 
FROM dbo.NashvilleHousing;


/* Checking if there are any duplicates */
WITH RowNumCTE AS (
SELECT *,  
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) AS row_num
FROM dbo.NashvilleHousing)
SELECT * 
FROM RowNumCTE
WHERE row_num > 1;


----------------------------------------------------------------
-- Delete irrelevant columns

SELECT * 
FROM dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate;