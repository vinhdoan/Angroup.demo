//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

namespace LogicLayer
{
    public class SurveyQuestion
    {
        public int QuestionNumber;
        public string QuestionText;
        public double Importance;

        //Constructor for SurveyQuestion. 
        public SurveyQuestion(int questionNumber, string questionText)
        {
            QuestionNumber = questionNumber;
            QuestionText = questionText;
        }
    }
}
