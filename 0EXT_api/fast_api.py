from fastapi import FastAPI
from faker import Faker
from faker.providers import internet, profile, user_agent

fake = Faker('en_US')
app = FastAPI(title="Fake Data API", version="1.0.0")

# Profile endpoints
@app.get("/")
def read_root():
    return {"url": "xyz.xyz.com"}

@app.get("/api/profile")
def get_fake_profile():
    """Generate a fake user profile with user agent."""
    return fake.profile() | {'user_agent': fake.user_agent()}

# Add more endpoints here following the same pattern
# Example:
# @app.get("/api/user")
# def get_fake_user():
#     return {"name": fake.name(), "email": fake.email()}
#
@app.get("/api/address")
def get_fake_address():
    return fake.address()

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)