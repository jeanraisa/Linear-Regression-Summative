from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import numpy as np
from fastapi.middleware.cors import CORSMiddleware

# Load the trained model
model = joblib.load("insurance.joblib")


# Define the data model
class InputData(BaseModel):
    age: int
    sex: str
    bmi: float
    children: int
    smoker: str


# Initialize FastAPI
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"message": "Welcome to the Insurance Charges Prediction API"}


@app.post("/predict")
def predict(data: InputData):
    # Encoding categorical variables
    sex_encoded = 1 if data.sex == "male" else 0
    smoker_encoded = 1 if data.smoker == "yes" else 0

    # Prepare the input data for prediction
    input_data = np.array(
        [[data.age, sex_encoded, data.bmi, data.children, smoker_encoded]]
    )

    # Make prediction
    prediction = model.predict(input_data)

    # Return the prediction as a response
    return {"prediction": round(prediction[0], 2)}
