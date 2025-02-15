CREATE TABLE `/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: TriNetX/raw_trinetx/Site 777/transform/04 - domain mapping/measurement`
TBLPROPERTIES (foundry_transform_profile = 'high-memory') AS

WITH diag_lab_proc_vital AS (
    SELECT 
        diagnosis.patient_id AS site_patient_id,
        CAST(diagnosis.date as date) AS measurement_date,
        CAST(diagnosis.date as timestamp) AS measurement_datetime,
        CAST(null as string) AS measurement_time,
        0 AS measurement_type_concept_id,
        CAST(null as int) AS operator_concept_id,
        CAST(null as float) AS value_as_number,
        CAST(null as float) AS range_low,
        CAST(null as float) AS range_high,	
        CAST(null as long) AS provider_id,
        diagnosis.encounter_id AS site_encounter_id,
        CAST(null as long) AS visit_detail_id,
        CAST(COALESCE(diagnosis.mapped_code, diagnosis.dx_code) as string) AS measurement_source_value,	
        CAST(null as string) AS unit_source_value,
        CAST(null as string) AS value_source_value,
        -- Mapped columns to be used for joins 
        PREPARED_COALESCED_MAPPED_CODE_SYSTEM AS mapped_code_system,
        CAST(null as string) AS result_type, -- Use so that we only lookup qualitative values to join on the concept table
        CAST(null as string) AS text_result_val,
        CAST(data_partner_id as int) as data_partner_id,
        payload
    FROM  `/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: TriNetX/raw_trinetx/Site 777/transform/03 - prepared/diagnosis` diagnosis

    UNION ALL

    SELECT 
        lab_result.patient_id AS site_patient_id,
        CAST(lab_result.test_date as date) AS measurement_date,
        CAST(lab_result.test_date as timestamp) AS measurement_datetime,
        CAST(null as string) AS measurement_time,
        0 AS measurement_type_concept_id,
        CAST(null as int) AS operator_concept_id,
        CAST(lab_result.numeric_result_val as float) AS value_as_number,
        CAST(null as float) AS range_low,
        CAST(null as float) AS range_high,	
        CAST(null as long) AS provider_id,
        lab_result.encounter_id AS site_encounter_id,
        CAST(null as long) AS visit_detail_id,
        CAST(COALESCE(lab_result.mapped_code, lab_result.lab_code) as string) AS measurement_source_value,	
        CAST(lab_result.units_of_measure as string) AS unit_source_value,
        'result_type:' || COALESCE(lab_result.result_type, '') 
            || '|numeric_result_val:' || COALESCE(lab_result.numeric_result_val, '') 
            || '|text_result_val:' || COALESCE(lab_result.text_result_val, '')
            || '|mapped_text_result_val:' || COALESCE(lab_result.mapped_text_result_val, '') as value_source_value,
        -- Mapped columns to be used for joins 
        PREPARED_COALESCED_MAPPED_CODE_SYSTEM AS mapped_code_system,
        lab_result.result_type AS result_type, -- Use so that we only lookup qualitative values to join on the concept table
        COALESCE(lab_result.mapped_text_result_val, lab_result.text_result_val) as text_result_val,
        CAST(data_partner_id as int) as data_partner_id,
		payload
    FROM `/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: TriNetX/raw_trinetx/Site 777/transform/03 - prepared/lab_result` lab_result

    UNION ALL

    SELECT 
        procedure.patient_id AS site_patient_id,
        CAST(procedure.date as date) AS measurement_date,
        CAST(null as timestamp) AS measurement_datetime,
        CAST(null as string) AS measurement_time,
        0 AS measurement_type_concept_id,
        CAST(null as int) AS operator_concept_id,
        CAST(null as float) AS value_as_number,
        CAST(null as float) AS range_low,
        CAST(null as float) AS range_high,	
        CAST(null as long) AS provider_id,
        procedure.encounter_id AS site_encounter_id,
        CAST(null as long) AS visit_detail_id,
        CAST(COALESCE(procedure.mapped_code, procedure.px_code) as string) AS measurement_source_value,	
        CAST(null as string) AS unit_source_value,
        CAST(null as string) AS value_source_value,
        -- Mapped columns to be used for joins 
        PREPARED_COALESCED_MAPPED_CODE_SYSTEM AS mapped_code_system,
        CAST(null as string) AS result_type, -- Use so that we only lookup qualitative values to join on the concept table
        CAST(null as string) AS text_result_val,
        CAST(data_partner_id as int) as data_partner_id,
		payload
    FROM `/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: TriNetX/raw_trinetx/Site 777/transform/03 - prepared/procedure` procedure
    
    UNION ALL

    SELECT 
        vital_signs.patient_id AS site_patient_id,
        CAST(vital_signs.measure_date as date) AS measurement_date,
        CAST(vital_signs.measure_date as timestamp) AS measurement_datetime,
        CAST(null as string) AS measurement_time,
        0 AS measurement_type_concept_id,
        CAST(null as int) AS operator_concept_id,
        CAST(vital_signs.numeric_result_val as float) AS value_as_number,
        CAST(null as float) AS range_low,
        CAST(null as float) AS range_high,	
        CAST(null as long) AS provider_id,
        vital_signs.encounter_id AS site_encounter_id,
        CAST(null as long) AS visit_detail_id,
        CAST(COALESCE(vital_signs.mapped_code, vital_signs.vital_code) as string) AS measurement_source_value,	
        CAST(vital_signs.unit_of_measure as string) AS unit_source_value,
        'result_type:' || COALESCE(vital_signs.result_type, '') 
            || '|numeric_result_val:' || COALESCE(vital_signs.numeric_result_val, '') 
            || '|text_result_val:' || COALESCE(vital_signs.text_result_val, '') 
            || '|mapped_text_result_val:' || COALESCE(vital_signs.mapped_text_result_val, '') as value_source_value,
        -- Mapped columns to be used for joins 
        PREPARED_COALESCED_MAPPED_CODE_SYSTEM AS mapped_code_system,
        vital_signs.result_type AS result_type, -- Use so that we only lookup qualitative values to join on the concept table
        COALESCE(vital_signs.mapped_text_result_val, vital_signs.text_result_val) as text_result_val,
        CAST(data_partner_id as int) as data_partner_id,
		payload
    FROM `/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: TriNetX/raw_trinetx/Site 777/transform/03 - prepared/vital_signs` vital_signs
),

crosswalk_lookup AS (
    SELECT
      diag_lab_proc_vital.*
    , crosswalk.source_concept_id AS measurement_source_concept_id
    , crosswalk.target_concept_id AS measurement_concept_id
    FROM diag_lab_proc_vital
    INNER JOIN `/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: TriNetX/raw_trinetx/Site 777/transform/t2o_code_xwalk_standard` crosswalk
        ON upper(diag_lab_proc_vital.mapped_code_system) = upper(crosswalk.src_vocab_code)
        AND diag_lab_proc_vital.measurement_source_value = crosswalk.source_code
        AND crosswalk.target_domain_id = 'Measurement'
),

-- Get value_as_concept_ids for records with values in the valueset mapping 
value_as_concept_id_mapped AS (
    SELECT 
        crosswalk_lookup.*
      , COALESCE(CAST(valueset_mapping.TARGET_CONCEPT_ID as int), 0) as value_as_concept_id
    FROM crosswalk_lookup
    LEFT JOIN `/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: TriNetX/t2o_valueset_mapping_table` valueset_mapping
        ON valueset_mapping.CDM_TBL_COLUMN_NAME = 'text_result_val'
        AND lower(trim(crosswalk_lookup.text_result_val)) = lower(trim(valueset_mapping.SRC_CODE))
),

-- Get unit_concept_ids for records with values in the valueset mapping 
unit_concept_id_mapped AS (
    SELECT 
        value_as_concept_id_mapped.*
      --, CAST(valueset_mapping.TARGET_CONCEPT_ID as int) as unit_concept_id
    , CASE WHEN ISNULL(value_as_concept_id_mapped.unit_source_value) then null 
    ELSE CAST( valueset_mapping.TARGET_CONCEPT_ID As int)
    END AS unit_concept_id
    FROM value_as_concept_id_mapped
    LEFT JOIN `/UNITE/Data Ingestion & OMOP Mapping/Source Data Model: TriNetX/t2o_valueset_mapping_table` valueset_mapping
        ON valueset_mapping.CDM_TBL_COLUMN_NAME = 'units_of_measure'
        AND value_as_concept_id_mapped.unit_source_value = valueset_mapping.SRC_CODE
),

final_table as (
-- Finding only unique measurements, per discussion with Matvey Palchuk + Kristin Kosta 13-08-2020
    SELECT DISTINCT
          *
    FROM unit_concept_id_mapped
    WHERE measurement_concept_id IS NOT NULL
)

SELECT 
    -- 2251799813685247 = ((1 << 51) - 1) - bitwise AND gives you the first 51 bits
      cast(base_10_hash_value as bigint) & 2251799813685247 as measurement_id_51_bit
    -- Pass through the hashed id to join on lookup table in case of conflicts
    , hashed_id
    , site_patient_id
    , measurement_concept_id
    , measurement_date
    , measurement_datetime
    , measurement_time
    , measurement_type_concept_id
    , operator_concept_id
    , value_as_number
    , value_as_concept_id
    , unit_concept_id
    , range_low
    , range_high
    , provider_id
    , site_encounter_id
    , visit_detail_id
    , measurement_source_value
    , measurement_source_concept_id
    , unit_source_value
    , value_source_value
    , data_partner_id
	, payload
FROM (
    SELECT
          *
        , conv(sub_hash_value, 16, 10) as base_10_hash_value
    FROM (
        SELECT
              * 
            , substr(hashed_id, 1, 15) as sub_hash_value
        FROM (
            SELECT
                  *
                -- Create primary key by concatenating row, hashing to 128bit hexademical with md5,
                -- and converting to 51 bit int by first taking first 15 hexademical digits and converting
                --  to base 10 (60 bit) and then bit masking to extract the first 51 bits
                , md5(concat_ws(
                    ';'
                    , COALESCE(site_patient_id, ' ')
                    , COALESCE(measurement_concept_id, ' ')
                    , COALESCE(measurement_date, ' ')
                    , COALESCE(measurement_datetime, ' ')
                    , COALESCE(measurement_time, ' ')
                    , COALESCE(measurement_type_concept_id, ' ')
                    , COALESCE(operator_concept_id, ' ')
                    , COALESCE(value_as_number, ' ')
                    , COALESCE(value_as_concept_id, ' ')
                    , COALESCE(unit_concept_id, ' ')
                    , COALESCE(range_low, ' ')
                    , COALESCE(range_high, ' ')
                    , COALESCE(provider_id, ' ')
                    , COALESCE(site_encounter_id, ' ')
                    , COALESCE(visit_detail_id, ' ')
                    , COALESCE(measurement_source_value, ' ')
                    , COALESCE(measurement_source_concept_id, ' ')
                    , COALESCE(unit_source_value, ' ')
                    , COALESCE(value_source_value, ' ')
                )) as hashed_id
            FROM final_table
        )
    )
)
