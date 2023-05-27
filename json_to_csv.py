import json, requests
import pandas as pd

url = "https://api.patentsview.org/patents/query?q=%7B%22_and%22:[%7B%22_gte%22:%7B%22patent_year%22:%222010%22%7D%7D,%7B%22cpc_section_id%22:%22G%22%7D,%7B%22cpc_subsection_id%22:%22G01%22%7D,%7B%22cpc_group_id%22:%22G01B%22%7D]%7D&f=[%22patent_number%22,%22patent_title%22,%22patent_abstract%22,%22patent_date%22,%22app_number%22,%22app_date%22,%22inventor_location_id%22,%22assignee_location_id%22,%22cited_patent_number%22,%22citedby_patent_number%22,%22cpc_section_id%22,%22cpc_group_id%22,%22cpc_subgroup_id%22,%22cpc_group_title%22,%22cpc_subgroup_title%22]&s=[%7B%22patent_title%22:%22asc%22%7D]"
data = requests.get(url).text

df = pd.read_json(data)
patents = df['patents']
print(patents)
df.to_csv('result.csv')