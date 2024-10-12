--Question 1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT prescriber.npi
	,	 SUM(prescription.total_claim_count) AS total_claims
FROM prescriber AS prescriber
	INNER JOIN prescription AS prescription
		ON prescriber.npi = prescription.npi
GROUP BY prescriber.npi
ORDER BY total_claims DESC
LIMIT 1;

--Answer 1.a. 1881634483 has the highest number number of cliams total of 99707

--Question 1. b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT prescriber.nppes_provider_first_name
	,    prescriber.nppes_provider_last_org_name
	,    prescriber.specialty_description
	,    SUM(prescription.total_claim_count) AS total_claims
FROM prescriber AS prescriber
	INNER JOIN prescription AS prescription
		ON prescriber.npi = prescription.npi
GROUP BY prescriber.nppes_provider_first_name
	,    prescriber.nppes_provider_last_org_name
	,    prescriber.specialty_description
ORDER BY 
    total_claims DESC
LIMIT 1;

-- Answer 1.b. BRUCE PENDLEY, specialty discription Family Practice and total claims 99707

--Question 2. a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT prescriber.specialty_description
	,	SUM(prescription.total_claim_count) AS total_claims
FROM prescriber AS prescriber
	INNER JOIN prescription AS prescription 
		ON prescriber.npi = prescription.npi
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

-- Answer 2. a. Family practice with 9752347 claim

--Question 2. b. Which specialty had the most total number of claims for opioids?

SELECT prescriber.specialty_description
	,	SUM(prescription.total_claim_count) AS total_claims
FROM prescriber AS prescriber
	INNER JOIN prescription AS prescription 
		ON prescriber.npi = prescription.npi
	INNER JOIN drug AS drug 
		ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC
LIMIT 1;

-- Answer 2.b. Nurse Practitioner with 900845 claims

--Question 2.c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT  DISTINCT p.specialty_description
FROM prescriber As p
	LEFT JOIN prescription AS pr 
		ON p.npi = pr.npi
WHERE pr.npi IS NULL;

--Answer 2.c. without using distinct i have total of 1000 rows by using distinct it gives me 92 rows..

--Question 3.a. Which drug (generic_name) had the highest total drug cost

SELECT d.generic_name
	,	SUM(pr.total_drug_cost) AS total_cost
FROM drug AS d
	INNER JOIN prescription AS pr 
		ON d.drug_name = pr.drug_name
GROUP BY d.generic_name
ORDER BY total_cost DESC
LIMIT 1;


--Answer. INSULIN GLARGINE,HUM.REC.ANLOG

--Question 3.b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT d.generic_name
	,	ROUND(SUM(pr.total_drug_cost) / SUM(pr.total_day_supply), 2) cost_per_day
FROM drug AS d
	INNER JOIN prescription AS pr 
		ON d.drug_name = pr.drug_name
GROUP BY d.generic_name
ORDER BY cost_per_day DESC
LIMIT 1;

--Answer 3.b. C1 ESTERASE INHIBITOR and cost per day 3495.22

-- Question 4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT drug_name
	,   CASE
        	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
       	 	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
        ELSE 'neither'
    END AS drug_type
FROM drug;

--Answer: run the querry to see result

--Question 4. b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT drug_type
	,	SUM(total_drug_cost)::MONEY AS total_cost
	FROM (SELECT d.drug_name
	,
    CASE
    	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
        WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
    ELSE 'neither'
        END AS drug_type
	,   total_drug_cost
FROM  drug AS d 
    INNER JOIN prescription ON d.drug_name = prescription.drug_name) AS drug_costs
WHERE drug_type IN ('opioid', 'antibiotic')
GROUP BY drug_type;

--Answer: the total cost for antiobiotic is "$38,435,121.26" and for opioid "$105,080,626.37"

--Question 5.a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT  COUNT(DISTINCT cbsa) AS number_of_cbsas
FROM   cbsa
	INNER JOIN  fips_county ON cbsa.fipscounty = fips_county.fipscounty
WHERE fips_county.state = 'TN';

--Answer: 10 CBSAs in 'TN'

--Question 5.b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population

SELECT cb.cbsa
	,	 cb.cbsaname
	,    SUM(p.population) AS total_population
FROM cbsa AS cb
    INNER JOIN population AS p 
		ON cb.fipscounty = p.fipscounty
GROUP BY cb.cbsa, cb.cbsaname
--ORDER BY total_population DESC for largest population
ORDER BY total_population ASC -- for Smallest popuation

-- largest population "Nashville-Davidson--Murfreesboro--Franklin, TN"  with total popuation 1830410...if we order by ASC so the smallest cbsa population is "Morristown, TN" with total population 116352 

--Question 5. c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT fc.county
	,	p.population
FROM population AS p
	INNER JOIN  fips_county AS fc 
		ON p.fipscounty = fc.fipscounty
	LEFT JOIN cbsa AS cb 
		ON fc.fipscounty = cb.fipscounty
WHERE cb.cbsa IS NULL
ORDER BY p.population DESC

--Answer: largest county in terms of population is SEVIER with total '95523' ppopulation

---SELECT  f.county
--	,    p.population
--FROM  fips_county AS f
--	INNER JOIN    population AS p 
--		ON f.fipscounty = p.fipscounty
--WHERE f.fipscounty NOT IN (SELECT fipscounty FROM cbsa)
--ORDER BY p.population DESC
--LIMIT 1;

--Question 6. a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count

SELECT  drug_name
	,	total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--Answer: total of 9 rows with drug name and total claim.. run querry to see the result

--Question 6. b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid. 

SELECT p.drug_name
	,	p.total_claim_count, d.opioid_drug_flag,
    CASE
        WHEN d.opioid_drug_flag = 'Y' THEN 'Yes'
        ELSE 'No'
    END AS is_opioid
FROM prescription AS p
	INNER JOIN drug AS d 
		ON p.drug_name = d.drug_name
WHERE 
    p.total_claim_count >= 3000;

--Answer: out of 9 rows only 2 rows are where drug is an opioid

--Question 6.c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT  p.drug_name
	,   p.total_claim_count,
    CASE
        WHEN d.opioid_drug_flag = 'Y' THEN 'Yes'
        ELSE 'No'
    END AS is_opioid,
    pr.nppes_provider_first_name AS prescriber_first_name,
    pr.nppes_provider_last_org_name AS prescriber_last_name
FROM  prescription AS p
	INNER JOIN  drug AS d 
		ON p.drug_name = d.drug_name
	INNER JOIN  prescriber AS pr 
		ON p.npi = pr.npi
WHERE  p.total_claim_count >= 3000;

--Answer.. run the query to see the result


--Question 7. a . 

SELECT pr.npi
	,	d.drug_name
FROM prescriber AS pr
	INNER JOIN drug AS d 
		ON d.opioid_drug_flag = 'Y'
WHERE pr.specialty_description = 'Pain Management' 
    AND pr.nppes_provider_city = 'NASHVILLE';

--Answer.. total rows 637

--Question 7.b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT prescriber.npi
		,	drug.drug_name
		,	SUM(prescription.total_claim_count) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;

-- SELECT pr_drug.npi, pr_drug.drug_name,
--    COALESCE(p.total_claim_count, 0) AS total_claim_count
-- FROM (SELECT   pr.npi, d.drug_name
-- FROM  prescriber AS pr
--    CROSS JOIN (SELECT drug_name FROM drug WHERE opioid_drug_flag = 'Y') d
-- WHERE pr.specialty_description = 'Pain Management' 
--       AND pr.nppes_provider_city = 'NASHVILLE') AS pr_drug
-- LEFT JOIN prescription AS p ON pr_drug.npi = p.npi AND pr_drug.drug_name = p.drug_name;

--Answer: total rows 637 

--Question 7.c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT prescriber.npi
		,	drug.drug_name
		,	COALESCE(SUM(prescription.total_claim_count), 0) AS sum_total_claims
	FROM prescriber
		CROSS JOIN drug
		LEFT JOIN prescription
			USING (drug_name)
	WHERE prescriber.specialty_description = 'Pain Management'
		AND prescriber.nppes_provider_city = 'NASHVILLE'
		AND drug.opioid_drug_flag = 'Y'
	GROUP BY prescriber.npi
		,	drug.drug_name
	ORDER BY prescriber.npi;

--Answer: total of 637 rows


