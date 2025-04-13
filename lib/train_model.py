from sklearn.ensemble import RandomForestClassifier
import joblib
X = [
    [5, 0, 0, 0],  
    [8, 1, 1, 0], 
    [12, 1, 1, 1],  
]
y = [2, 1, 0]  
model = RandomForestClassifier()
model.fit(X, y)
joblib.dump(model, 'model.pkl')

