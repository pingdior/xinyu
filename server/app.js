const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());

// 添加CORS配置
app.use(cors());

// 添加健康检查接口
app.get('/', (req, res) => {
    res.json({ status: 'ok', message: 'XinYu API Server is running' });
});

// 连接MongoDB数据库
mongoose.connect('mongodb://localhost:27017/xinyu', {
    useNewUrlParser: true,
    useUnifiedTopology: true
});

// 定义评估数据模型
const AssessmentSchema = new mongoose.Schema({
    id: String,
    userId: String,
    inputText: String,
    inputType: String,
    assessmentTimestamp: Date,
    positiveScore: Number,
    negativeScore: Number,
    stressLevel: Number,
    anxietyLevel: Number,
    riskLevel: String,
    reportText: String
});

const Assessment = mongoose.model('Assessment', AssessmentSchema);

// 定义匿名评估数据模型
const AnonymousAssessmentSchema = new mongoose.Schema({
    positiveScore: Number,
    negativeScore: Number,
    stressLevel: Number,
    anxietyLevel: Number,
    riskLevel: String,
    timestamp: { type: Date, default: Date.now }
});

const AnonymousAssessment = mongoose.model('AnonymousAssessment', AnonymousAssessmentSchema);

// API路由
app.post('/api/assessments', async (req, res) => {
    try {
        const assessment = new Assessment(req.body);
        await assessment.save();
        res.status(201).json({
            success: true,
            assessment: {
                positiveScore: assessment.positiveScore,
                negativeScore: assessment.negativeScore,
                stressLevel: assessment.stressLevel,
                anxietyLevel: assessment.anxietyLevel,
                riskLevel: assessment.riskLevel,
                reportText: assessment.reportText
            }
        });
    } catch (error) {
        console.error('保存评估数据失败:', error);
        res.status(500).json({ error: '服务器错误' });
    }
});

app.post('/api/assessments/anonymous', async (req, res) => {
    try {
        const anonymousAssessment = new AnonymousAssessment(req.body);
        await anonymousAssessment.save();
        res.status(201).json({ message: '匿名评估数据保存成功' });
    } catch (error) {
        console.error('保存匿名评估数据失败:', error);
        res.status(500).json({ error: '服务器错误' });
    }
});

// 启动服务器
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`服务器运行在端口 ${port}`);
});