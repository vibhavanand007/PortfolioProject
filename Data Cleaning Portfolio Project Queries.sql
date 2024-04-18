/*

Cleaning Data in SQL Queries

*/

USE ProjectPortfolio

SELECT *
FROM ProjectPortfolio..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted
FROM ProjectPortfolio..NashvilleHousing

UPDATE ProjectPortfolio..NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

-- If it doesn't Update properly

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE ProjectPortfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM ProjectPortfolio..NashvilleHousing
WHERE PropertyAddress IS NULL



SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing A
JOIN ProjectPortfolio..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing A
JOIN ProjectPortfolio..NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)



--PropertyAddress
SELECT PropertyAddress
FROM ProjectPortfolio..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM ProjectPortfolio..NashvilleHousing




ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM ProjectPortfolio..NashvilleHousing





--OwnerAddress

SELECT OwnerAddress
FROM ProjectPortfolio..NashvilleHousing
WHERE OwnerAddress IS NOT NULL


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM ProjectPortfolio..NashvilleHousing
WHERE OwnerAddress IS NOT NULL


ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE ProjectPortfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM ProjectPortfolio..NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'YES' THEN 'Yes'
	   WHEN SoldAsVacant = 'NO' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM ProjectPortfolio..NashvilleHousing

UPDATE ProjectPortfolio..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM ProjectPortfolio..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY [UniqueID ]





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM ProjectPortfolio..NashvilleHousing

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE ProjectPortfolio..NashvilleHousing
DROP COLUMN SaleDate






















