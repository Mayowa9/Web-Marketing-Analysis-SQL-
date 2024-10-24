--Question 1

SELECT TOP 3
    Page_Impressions$.page_path,
    COUNT(Page_Impressions$.impression_id) AS total_impressions,
    (SUM(CASE WHEN Page_Impressions$.bot = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(Page_Impressions$.impression_id) AS bot_percentage
FROM 
    Page_Impressions$
GROUP BY 
    Page_Impressions$.page_path
ORDER BY 
    total_impressions DESC;

-- Question 2

WITH TOPTEN AS (
    SELECT 
        Page_Impressions$.page_path,
        Page_Impressions$.ui_user_id,
        SUM(Page_Impressions$.time_on_page_seconds) AS total_time_on_page,
        ROW_NUMBER() OVER (PARTITION BY Page_Impressions$.page_path ORDER BY SUM(Page_Impressions$.time_on_page_seconds) DESC) AS rank
    FROM Page_Impressions$
    WHERE Page_Impressions$.bot = 0  -- Exclude bots 
    GROUP BY Page_Impressions$.page_path, Page_Impressions$.ui_user_id
)
SELECT 
    page_path,
    ui_user_id,
    total_time_on_page
FROM TOPTEN
WHERE rank <= 10
ORDER BY page_path, rank;


-- Question 3

SELECT 
    Page_Impressions$.ui_user_id, 
    Page_Impressions$.page_path,
    COUNT(DISTINCT CAST(Page_Impressions$.utc_date_time AS DATE)) AS distinct_days
FROM 
    Page_Impressions$
WHERE 
    Page_Impressions$.bot = 0 -- Exclude bots
GROUP BY 
    Page_Impressions$.ui_user_id, 
    Page_Impressions$.page_path
HAVING 
    COUNT(DISTINCT CAST(Page_Impressions$.utc_date_time AS DATE)) > 1; 


-- Question 4

SELECT DISTINCT Page_Impressions$.ui_user_id
FROM Page_Impressions$
JOIN User_Info$ ON Page_Impressions$.ui_user_id = User_Info$.ui_user_id
WHERE Page_Impressions$.page_path = 'citywire.com/new-model-adviser/news/steer-clear-of-the-accountability-sink/a2449573'
AND User_Info$.core_audience = 1;

-- Question 5

WITH UserBounceStatus AS (
    SELECT 
        Page_Impressions$.ui_user_id,
        Page_Impressions$.page_path,
        MAX(CASE WHEN Page_Impressions$.time_on_page_seconds > 2 THEN 1 ELSE 0 END) AS has_non_bounce,
        MIN(CASE WHEN Page_Impressions$.time_on_page_seconds <= 2 THEN 1 ELSE 0 END) AS has_bounce
    FROM 
        Page_Impressions$
    GROUP BY 
        Page_Impressions$.ui_user_id,
        Page_Impressions$.page_path
),
BounceProportion AS (
    SELECT
        page_path,
        COUNT(CASE WHEN has_non_bounce = 0 AND has_bounce = 1 THEN 1 END) AS bounce_only_users,
        COUNT(DISTINCT ui_user_id) AS total_users
    FROM 
        UserBounceStatus
    GROUP BY 
        page_path
)
SELECT
    page_path,
    bounce_only_users,
    total_users,
    (CAST(bounce_only_users AS FLOAT) / total_users) AS bounce_proportion
FROM 
    BounceProportion;

-- Question 6 

WITH PageViews AS (
    SELECT
        Page_Impressions$.ui_user_id,
        Page_Impressions$.page_path,
        CONVERT(DATE, Page_Impressions$.utc_date_time) AS view_date,
        Page_Impressions$.time_on_page_seconds,
        Page_Impressions$.bot,
        Page_Impressions$.device_type, 
        CASE 
            WHEN Page_Impressions$.time_on_page_seconds <= 2 THEN 1
            ELSE 0
        END AS is_bounce
    FROM Page_Impressions$
),
FilteredPageViews AS (
    SELECT
        PageViews.ui_user_id,
        PageViews.page_path,
        PageViews.view_date,
        PageViews.time_on_page_seconds,
        PageViews.bot,
        PageViews.device_type, 
        PageViews.is_bounce,
        CASE 
            WHEN PageViews.bot = 0 AND PageViews.is_bounce = 0 THEN 
                CONCAT(PageViews.ui_user_id, '_', PageViews.view_date, '_', Content.content_code)
            ELSE NULL
        END AS read_key
    FROM PageViews
    JOIN Test_Content$ AS Content
        ON PageViews.page_path LIKE CONCAT('%', Content.content_code, '%')
),
FinalDataset AS (
    SELECT
        fpv.ui_user_id,
        fpv.page_path,
        fpv.view_date,
        fpv.time_on_page_seconds,
        fpv.bot,
        fpv.device_type, 
        fpv.is_bounce,
        fpv.read_key,
        uinfo.core_audience,
        content.content_code,
        content.author,
        content.headline,
        content.surtitle,
        content.tag
    FROM FilteredPageViews AS fpv
    LEFT JOIN User_Info$ AS uinfo
        ON fpv.ui_user_id = uinfo.ui_user_id
    LEFT JOIN Test_Content$ AS content
        ON fpv.page_path LIKE CONCAT('%', content.content_code, '%')
)
SELECT * FROM FinalDataset;


