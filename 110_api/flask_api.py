from flask import Flask
from faker import Faker
from faker.providers import internet, profile, user_agent

fake = Faker('en_US')
app = Flask(__name__)

@app.route('/profile')
def fake_profile():
    return fake.profile() | {'user_agent':fake.user_agent()}

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)