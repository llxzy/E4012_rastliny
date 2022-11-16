import pandas as pd
import numpy as np

from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier, plot_tree, export_text

from sklearn.neighbors import KNeighborsClassifier

from sklearn.neural_network import MLPClassifier

from sklearn.ensemble import RandomForestClassifier

from sklearn.metrics import precision_score, classification_report

import matplotlib.pyplot as plt

def main():
    dt = pd.read_csv("data.csv")
    print(dt.dtypes)

    labels = dt["ROI name"]
    dt = dt.drop(columns=["ROI name"])
    labels = labels.astype("category")

    # drop tray and x/y values
    #dt = dt.drop(columns=["Tray", "File X", "File Y"])

    print(dt.columns)
    X_train, X_test, y_train, y_test = train_test_split(dt, labels, shuffle=True, test_size=0.3)

    # classifier = KNeighborsClassifier(n_neighbors=3)

    classifier = DecisionTreeClassifier(criterion="gini", max_depth=10)
    #classifier = RandomForestClassifier(max_depth=20)

    # pipeline = Pipeline(
    #     ["KNN", classifier]
    # )
    pipeline = classifier

    pipeline.fit(X_train, y_train)
    predict = pipeline.predict(X_test)

    print(classification_report(y_test, predict))

    text_repr = export_text(classifier, feature_names=list(dt.columns))
    print(text_repr)
    # fig = plt.figure(figsize=(25,20), dpi=300)
    # plot_tree(classifier, 
    #                feature_names=list(dt.columns),  
    #                class_names=list(set(labels)),
    #                filled=True)

    # fig.show()
    # #print(labels)
    # #print(dt)
    # fig.savefig("result.png")


main()