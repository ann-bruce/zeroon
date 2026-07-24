import { useState } from 'react'
import { Alert, Button, Card, Col, Input, Row, Space, Typography } from 'antd'
import { ReloadOutlined, SafetyCertificateOutlined } from '@ant-design/icons'

type MetricCell = {
  suppressed: boolean
  numerator: number | null
  denominator: number | null
  rate: number | null
}

type CountCell = {
  suppressed: boolean
  events: number | null
  subjects: number | null
}

type DistributionCell = CountCell

type EvidenceResponse = {
  cohortStart: string
  cohortEnd: string
  asOfDate: string
  minimumCohortSize: number
  suppressed: boolean
  activationCoverage: string | null
  authenticatedSubjects: number | null
  activation: MetricCell | null
  dayOneRetention: MetricCell | null
  daySevenRetention: MetricCell | null
  dayThirtyRetention: MetricCell | null
  weekTwoRecord: MetricCell | null
  currentWeekContinuityReview: MetricCell | null
  currentWeekChatOnly: MetricCell | null
  recordFlowCompletion: MetricCell | null
  reliability: {
    recordSaved: CountCell
    recordSaveFailed: CountCell
    recordSaveSuccess: MetricCell
    recoveredRetry: MetricCell
    reflectionOutcomes: Record<string, DistributionCell>
    reflectionLatencyBuckets: Record<string, DistributionCell>
  } | null
  trustControls: {
    aiContextDisabledSubjects: MetricCell
    memoryDeletionSubjects: MetricCell
    dataExportDemand: MetricCell
    accountDeletionDemand: MetricCell
  } | null
  interpretationNotice: string
}

const tokenStorageKey = 'zeroon.admin.accessToken'

function isoDate(date: Date) {
  return date.toISOString().slice(0, 10)
}

function percent(rate: number | null) {
  return rate === null ? '尚未成熟' : `${(rate * 100).toFixed(1)}%`
}

function MetricCard({ label, cell }: { label: string; cell: MetricCell | null }) {
  const hidden = !cell || cell.suppressed
  return (
    <Card size="small" className="evidence-metric-card">
      <Typography.Text type="secondary">{label}</Typography.Text>
      <Typography.Title level={3} className="evidence-value">
        {hidden ? '暂不显示' : percent(cell.rate)}
      </Typography.Title>
      <Typography.Text type="secondary">
        {hidden
          ? '样本不足，已按隐私规则抑制'
          : `${cell.numerator} / ${cell.denominator} 位可计算参与者`}
      </Typography.Text>
    </Card>
  )
}

function CountCard({ label, cell }: { label: string; cell: CountCell }) {
  return (
    <Card size="small" className="evidence-metric-card">
      <Typography.Text type="secondary">{label}</Typography.Text>
      <Typography.Title level={3} className="evidence-value">
        {cell.suppressed ? '暂不显示' : cell.events}
      </Typography.Title>
      <Typography.Text type="secondary">
        {cell.suppressed ? '涉及人数不足 5，已隐藏' : `来自 ${cell.subjects} 位参与者`}
      </Typography.Text>
    </Card>
  )
}

export default function EvidencePanel() {
  const today = new Date()
  const thirtyDaysAgo = new Date(today)
  thirtyDaysAgo.setDate(today.getDate() - 29)

  const [token, setToken] = useState(() => localStorage.getItem(tokenStorageKey) ?? '')
  const [cohortStart, setCohortStart] = useState(isoDate(thirtyDaysAgo))
  const [cohortEnd, setCohortEnd] = useState(isoDate(today))
  const [asOfDate, setAsOfDate] = useState(isoDate(today))
  const [report, setReport] = useState<EvidenceResponse | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function loadReport() {
    if (!token.trim()) {
      setError('请先填写后台访问令牌。')
      return
    }
    localStorage.setItem(tokenStorageKey, token.trim())
    setLoading(true)
    setError(null)
    try {
      const params = new URLSearchParams({ cohortStart, cohortEnd, asOfDate })
      const response = await fetch(`/api/v1/admin/evidence/cohorts?${params}`, {
        headers: { Authorization: `Bearer ${token.trim()}` },
      })
      if (!response.ok) {
        throw new Error(response.status === 403 ? '当前账号没有 ADMIN 权限。' : `读取失败：${response.status}`)
      }
      setReport((await response.json()) as EvidenceResponse)
    } catch (caught) {
      setReport(null)
      setError(caught instanceof Error ? caught.message : '证据报告读取失败')
    } finally {
      setLoading(false)
    }
  }

  const metrics: Array<[string, MetricCell | null]> = report
    ? [
        ['完整激活', report.activation],
        ['D1 回访', report.dayOneRetention],
        ['D7 回访', report.daySevenRetention],
        ['D30 回访', report.dayThirtyRetention],
        ['第二周保存 Record', report.weekTwoRecord],
        ['近 7 日连续性回看', report.currentWeekContinuityReview],
        ['近 7 日仅聊天', report.currentWeekChatOnly],
        ['Reset → Record 完成', report.recordFlowCompletion],
      ]
    : []

  return (
    <section className="panel evidence-panel">
      <Space direction="vertical" size="large" className="full-width">
        <div>
          <Typography.Title level={2}>Beta 证据</Typography.Title>
          <Typography.Paragraph>
            只读查看匿名聚合结果，用来判断 ZEROON 是否形成持续陪伴价值。这里不会显示用户、
            单条事件、私人内容或个人时间线。
          </Typography.Paragraph>
        </div>

        <Alert
          type="info"
          showIcon
          icon={<SafetyCertificateOutlined />}
          message="隐私边界"
          description="少于 5 位参与者的 cohort 会整体隐藏；达到门槛后，涉及人数不足 5 的派生单元仍会分别隐藏。"
        />

        <Card>
          <Space direction="vertical" size="middle" className="full-width">
            <Input.Password
              placeholder="粘贴后台访问令牌"
              value={token}
              onChange={(event) => setToken(event.target.value)}
            />
            <div className="evidence-filters">
              <label>
                <span>首次认证起始日</span>
                <Input type="date" value={cohortStart} onChange={(event) => setCohortStart(event.target.value)} />
              </label>
              <label>
                <span>首次认证结束日</span>
                <Input type="date" value={cohortEnd} onChange={(event) => setCohortEnd(event.target.value)} />
              </label>
              <label>
                <span>计算截止日</span>
                <Input type="date" value={asOfDate} onChange={(event) => setAsOfDate(event.target.value)} />
              </label>
              <Button type="primary" icon={<ReloadOutlined />} loading={loading} onClick={loadReport}>
                读取聚合结果
              </Button>
            </div>
          </Space>
        </Card>

        {error ? <Alert type="warning" showIcon message={error} /> : null}

        {report?.suppressed ? (
          <Card className="evidence-empty-card">
            <Typography.Title level={4}>当前 cohort 暂不显示</Typography.Title>
            <Typography.Paragraph type="secondary">
              参与者不足 {report.minimumCohortSize} 位。系统不会返回实际人数或任何派生指标。
            </Typography.Paragraph>
          </Card>
        ) : null}

        {report && !report.suppressed ? (
          <>
            <Card>
              <Typography.Text type="secondary">可纳入计算的认证参与者</Typography.Text>
              <Typography.Title level={2} className="evidence-subject-count">
                {report.authenticatedSubjects} 位
              </Typography.Title>
              <Typography.Text type="secondary">
                日期按 Asia/Shanghai 日历日计算；留存事件缺失、关闭采集和指标成熟度会影响解释。
              </Typography.Text>
            </Card>

            <div>
              <Typography.Title level={4}>产品连续性</Typography.Title>
              <Row gutter={[12, 12]}>
                {metrics.map(([label, cell]) => (
                  <Col xs={24} sm={12} lg={8} xl={6} key={label}>
                    <MetricCard label={label} cell={cell} />
                  </Col>
                ))}
              </Row>
            </div>

            {report.reliability ? (
              <div>
                <Typography.Title level={4}>运行可靠性</Typography.Title>
                <Row gutter={[12, 12]}>
                  <Col xs={24} sm={12} lg={6}>
                    <CountCard label="Record 保存事件" cell={report.reliability.recordSaved} />
                  </Col>
                  <Col xs={24} sm={12} lg={6}>
                    <CountCard label="Record 保存失败" cell={report.reliability.recordSaveFailed} />
                  </Col>
                  <Col xs={24} sm={12} lg={6}>
                    <MetricCard label="Record 保存成功率" cell={report.reliability.recordSaveSuccess} />
                  </Col>
                  <Col xs={24} sm={12} lg={6}>
                    <MetricCard label="重试后恢复" cell={report.reliability.recoveredRetry} />
                  </Col>
                </Row>
              </div>
            ) : null}

            {report.trustControls ? (
              <div>
                <Typography.Title level={4}>信任控制</Typography.Title>
                <Row gutter={[12, 12]}>
                  <Col xs={24} sm={12} lg={6}>
                    <MetricCard label="关闭 AI 上下文" cell={report.trustControls.aiContextDisabledSubjects} />
                  </Col>
                  <Col xs={24} sm={12} lg={6}>
                    <MetricCard label="删除 Memory" cell={report.trustControls.memoryDeletionSubjects} />
                  </Col>
                  <Col xs={24} sm={12} lg={6}>
                    <MetricCard label="请求数据导出" cell={report.trustControls.dataExportDemand} />
                  </Col>
                  <Col xs={24} sm={12} lg={6}>
                    <MetricCard label="请求注销账户" cell={report.trustControls.accountDeletionDemand} />
                  </Col>
                </Row>
              </div>
            ) : null}
          </>
        ) : null}
      </Space>
    </section>
  )
}
