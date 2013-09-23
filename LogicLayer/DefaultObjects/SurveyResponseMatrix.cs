//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using LogicLayer.Statistics; 

namespace LogicLayer
{
    public class SurveyResponseMatrix
    {
        public List<SurveyQuestion> SurveyQuestions;
        public List<double[]> SurveyResponses;
        public List<double> OverallSatisfaction;

        //Constructor
        public SurveyResponseMatrix()
        {
            SurveyQuestions = new List<SurveyQuestion>();
            SurveyResponses = new List<double[]>();
            OverallSatisfaction = new List<double>();
        }

        //adds SurveyQuestion to Survey. 
        public void AddSurveyQuestion(SurveyQuestion question)
        {
            SurveyQuestions.Add(question);
        }

        //adds survey responses and overall satisfactions into lists. 
        public void AddSurveyResponse(double[] responseValues, double overallSatisfaction)
        {
            SurveyResponses.Add(responseValues);
            OverallSatisfaction.Add(overallSatisfaction);
        }

        // Computes the importance of each question by solving
        // the b vector in Xb = y using the linear least squares method.
        public void ComputeSurveyQuestionImportance()
        {
            int rows = SurveyResponses.Count; 
            int columns = SurveyQuestions.Count; 
            if (rows < columns)
                throw new ArgumentException("Matrix is under-determined.");

            double[,] SurveyMatrix = new double[rows, columns];

            for (int i = 0; i < rows; ++i)
            {
                for (int j = 0; j < columns; ++j)
                    if ((SurveyResponses.Count - 1) >= i)
                    {
                        if ((SurveyResponses[i].Length - 1) >= j)
                            SurveyMatrix[i, j] = SurveyResponses[i][j];
                        else
                            SurveyMatrix[i, j] = 0;
                    }
                    else
                        SurveyMatrix[i, j] = 0;
            }

            double[] OverallSatisfactionVector = new double[rows];
            for(int i = 0; i < rows; ++i)
                OverallSatisfactionVector[i] = OverallSatisfaction[i];

            double[] ImportanceVector = new double[columns];
            ImportanceVector = LinearAlgebra.SolveLeastSquares(ref SurveyMatrix, 
                ref OverallSatisfactionVector);
            for (int i = 0; i < columns; ++i)
                SurveyQuestions[i].Importance = ImportanceVector[i]; 
        }

    }

}