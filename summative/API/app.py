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
    sex: int
    bmi: float
    children: int
    smoker: int


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
    # Convert input data to the required format for the model
    input_data = np.array([[data.age, data.sex, data.bmi, data.children, data.smoker]])

    # Make prediction
    prediction = model.predict(input_data)

    # Return the prediction as a response
    return {"prediction": round(prediction[0], 2)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)