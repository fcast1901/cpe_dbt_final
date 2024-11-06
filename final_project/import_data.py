
import os
import pandas as pd
from sqlalchemy import create_engine

# Conexión a la base de datos
engine = create_engine('postgresql://postgres:mysecretpassword@localhost:5432/postgres')

# Cargar archivo CSV

# Obtener el directorio actual del script
base_path = os.path.dirname(__file__)

# Definir rutas de archivos relativas al directorio padre
df_transactions = pd.read_csv(os.path.join(base_path, '..', 'transactions.csv'))
df_accounts = pd.read_csv(os.path.join(base_path, '..', 'accounts.csv'))
df_account_types = pd.read_csv(os.path.join(base_path, '..', 'account_types.csv'))

# Insertar en la tabla de la base de datos
df_transactions.to_sql('transactions', engine, if_exists='replace', index=False)
df_accounts.to_sql('accounts', engine, if_exists='replace', index=False)
df_account_types.to_sql('account_types', engine, if_exists='replace', index=False)