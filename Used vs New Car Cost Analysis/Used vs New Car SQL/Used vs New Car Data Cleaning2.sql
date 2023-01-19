
SELECT title,
	   cost,
	   scrape_date
	   INTO kbb_original [IN Used vs New Cars]
FROM [Used vs New Cars]..[kbb_web_scraping]
ORDER BY 2


-- Extracting first and second word from the title of each post
SELECT CASE CHARINDEX(' ', @Foo, 1)
     WHEN 0 THEN @Foo -- empty or single word
     ELSE SUBSTRING(@Foo, 1, CHARINDEX(' ', @Foo, 1) - 1) -- multi-word
END as new_or_used
FROM [Used vs New Cars]..[KBB Web Scraping Data].
