import streamlit as st
import pandas as pd

# ---------------- LOGIN SYSTEM ----------------

USER_CREDENTIALS = {
    "admin": "1234",
    "tanu": "password"
}

if "logged_in" not in st.session_state:
    st.session_state.logged_in = False

def login():
    st.set_page_config(page_title="Login", layout="centered")

    st.title("🔐 Customer Analytics Login")

    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        if username in USER_CREDENTIALS and USER_CREDENTIALS[username] == password:
            st.session_state.logged_in = True
            st.success("Login successful")
            st.rerun()
        else:
            st.error("Invalid credentials")

def logout():
    st.session_state.logged_in = False

# ---------------- PROFESSIONAL DASHBOARD ----------------

def dashboard():
    st.set_page_config(page_title="Dashboard", layout="wide")

    df = pd.read_csv("customer_shopping_behavior.csv")

    # Sidebar
    st.sidebar.title("🔎 Filters")
    st.sidebar.button("Logout", on_click=logout)

    category = st.sidebar.multiselect(
        "Category",
        df['Category'].unique(),
        default=df['Category'].unique()
    )

    gender = st.sidebar.multiselect(
        "Gender",
        df['Gender'].unique(),
        default=df['Gender'].unique()
    )

    filtered_df = df[
        (df['Category'].isin(category)) &
        (df['Gender'].isin(gender))
    ]

    # Title
    st.title("📊 Customer Analytics & Purchase Intelligence Dashboard")
    st.markdown("Real-time insights into customer behavior and sales performance")

    # KPIs
    col1, col2, col3 = st.columns(3)

    col1.metric("💰 Total Revenue", int(filtered_df['Purchase Amount (USD)'].sum()))
    col2.metric("🛒 Avg Purchase", round(filtered_df['Purchase Amount (USD)'].mean(), 2))
    col3.metric("👥 Customers", filtered_df.shape[0])

    # Charts Row 1
    col4, col5 = st.columns(2)

    with col4:
        st.subheader("Sales by Category")
        st.bar_chart(filtered_df.groupby('Category')['Purchase Amount (USD)'].sum())

    with col5:
        st.subheader("Gender-wise Spending")
        st.bar_chart(filtered_df.groupby('Gender')['Purchase Amount (USD)'].sum())

    # Segmentation
    def segment(row):
        if row['Purchase Amount (USD)'] > 80:
            return 'High Value'
        elif row['Purchase Amount (USD)'] > 50:
            return 'Medium Value'
        else:
            return 'Low Value'

    filtered_df['Segment'] = filtered_df.apply(segment, axis=1)

    col6, col7 = st.columns(2)

    with col6:
        st.subheader("Customer Segments")
        st.bar_chart(filtered_df['Segment'].value_counts())

    with col7:
        st.subheader("Top Customers")
        top = filtered_df.sort_values(by='Purchase Amount (USD)', ascending=False).head(10)
        st.dataframe(top)

# ---------------- MAIN ----------------

if st.session_state.logged_in:
    dashboard()
else:
    login()