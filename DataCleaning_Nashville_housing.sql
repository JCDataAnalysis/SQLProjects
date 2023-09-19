SELECT * FROM Projects.nashville_housing;

--Standarize Date Format

SELECT SaleDate, DATE(SaleDate) AS SaleDateConverted
FROM Projects.nashville_housing;

ALTER TABLE Projects.nashville_housing
ADD SaleDateConverted Date;

UPDATE Projects.nashville_housing
SET SaleDateConverted = DATE(SaleDate)

--Populate Property Address data 

SELECT PropertyAddress
FROM Projects.nashville_housing
WHERE PropertyAddress IS NULL;

SELECT * 
FROM Projects.nashville_housing
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM Projects.nashville_housing a
JOIN Projects.nashville_housing b
	ON a.ParcelID = b.ParcelID    
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;
    
UPDATE a
JOIN b ON a.ParcelID = b.ParcelID
       AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

--Breaking down Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Projects.nashville_housing

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) AS Address
FROM Projects.nashville_housing;

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address, 
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City 
FROM Projects.nashville_housing;

ALTER TABLE Projects.nashville_housing
ADD PropertySplitAddress nvarchar(255);

UPDATE Projects.nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

ALTER TABLE Projects.nashville_housing
ADD PropertySplitCity nvarchar(255);

UPDATE Projects.nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

SELECT OwnerAddress
FROM Projects.nashville_housing;

SELECT 
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS City,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM Projects.nashville_housing;

ALTER TABLE Projects.nashville_housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Projects.nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

ALTER TABLE Projects.nashville_housing
ADD OwnerSplitCity nvarchar(255);

UPDATE Projects.nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

ALTER TABLE Projects.nashville_housing
ADD OwnerSplitState nvarchar(255);

UPDATE Projects.nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


--Change Y and N into Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Projects.nashville_housing
GROUP BY SoldAsVacant;

SELECT 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
	END 
FROM Projects.nashville_housing;

UPDATE Projects.nashville_housing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
WHERE SoldAsVacant IN('Y', 'N');

--Remove duplicates 

DELETE t
FROM Projects.nashville_housing t
WHERE (SELECT COUNT(*)
       FROM Projects.nashville_housing
       WHERE ParcelID = t.ParcelID
         AND PropertyAddress = t.PropertyAddress
         AND SalePrice = t.SalePrice
         AND LegalReference = t.LegalReference
         AND UniqueID <= t.UniqueID) > 1;

--Delete unused columns

SELECT *
FROM Projects.nashville_housing;

ALTER TABLE Projects.nashville_housing
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN SaleDate;






