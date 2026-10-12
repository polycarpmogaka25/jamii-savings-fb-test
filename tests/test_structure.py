import unittest
from pathlib import Path
import xml.etree.ElementTree as ET
ROOT = Path(__file__).resolve().parents[1]
class StructureTests(unittest.TestCase):
 def test_xml_valid(self):
  for f in (ROOT/'wso2-mi/integrations/src/main/wso2mi/artifacts').rglob('*'):
   if f.suffix in ('.xml','.dbs'): ET.parse(f)
 def test_sql_parameterized(self):
  s=(ROOT/'wso2-mi/integrations/src/main/wso2mi/artifacts/data-services/AccountDS.dbs').read_text()
  self.assertIn(':accNumber',s)
 def test_three_apis(self):
  for name in ('AccountsAPI','CustomersAPI','LoansAPI'):
   self.assertTrue((ROOT/f'wso2-mi/integrations/src/main/wso2mi/artifacts/api/{name}.xml').exists())
if __name__=='__main__': unittest.main()
